import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:germana/core/config.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/map_styles.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/screens/explore/street_view_screen.dart';
import 'package:germana/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RideMapSnippet extends StatefulWidget {
  final String pickupLabel;
  final String destinationLabel;
  final double? pickupLat;
  final double? pickupLng;
  final double? destinationLat;
  final double? destinationLng;
  final double? userLat;
  final double? userLng;
  final double height;

  const RideMapSnippet({
    super.key,
    required this.pickupLabel,
    required this.destinationLabel,
    this.pickupLat,
    this.pickupLng,
    this.destinationLat,
    this.destinationLng,
    this.userLat,
    this.userLng,
    this.height = 210,
  });

  @override
  State<RideMapSnippet> createState() => _RideMapSnippetState();
}

class _RideMapSnippetState extends State<RideMapSnippet> {
  static bool _webStaticMapsBlockedForSession = false;

  GoogleMapController? _controller;
  final LocationService _locationService = LocationService();

  RouteDetails? _routeDetails;
  bool _isLoadingRoute = false;
  List<LatLng> _polylineLatLng = const [];
  BitmapDescriptor? _pickupMarkerIcon;
  BitmapDescriptor? _destinationMarkerIcon;
  bool? _markerIconsForDark;

  bool get _hasRouteCoords =>
      widget.pickupLat != null &&
      widget.pickupLng != null &&
      widget.destinationLat != null &&
      widget.destinationLng != null;

  bool get _hasUserCoords => widget.userLat != null && widget.userLng != null;

  @override
  void initState() {
    super.initState();
    _loadRouteDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_markerIconsForDark != isDark) {
      _prepareMarkerIcons();
    }
  }

  Future<void> _prepareMarkerIcons() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickup = await _buildCircleMarkerIcon(
      AppColors.routeStartBlue,
      outlineColor: Colors.white,
      outlineWidth: 1.0,
    );
    final destination = await _buildCircleMarkerIcon(
      isDark ? AppColors.routeEndNeutralDark : AppColors.routeEndNeutralLight,
    );
    if (!mounted) return;
    setState(() {
      _pickupMarkerIcon = pickup;
      _destinationMarkerIcon = destination;
      _markerIconsForDark = isDark;
    });
  }

  Future<BitmapDescriptor> _buildCircleMarkerIcon(
    Color color, {
    Color? outlineColor,
    double outlineWidth = 0,
  }) async {
    const size = 52.0;
    const supersample = 3.0;
    const outlinedRadius = 7.8;
    const fillRadiusWithOutline = 7.2;
    const fillRadius = 7.8;

    // Render at higher resolution first, then downsample to reduce jagged edges.
    final hiSize = size * supersample;
    final hiRecorder = ui.PictureRecorder();
    final hiCanvas = Canvas(hiRecorder);
    final hiCenter = Offset(hiSize / 2, hiSize / 2);

    if (outlineColor != null && outlineWidth > 0) {
      hiCanvas.drawCircle(
        hiCenter,
        outlinedRadius * supersample,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = outlineWidth * supersample
          ..color = outlineColor,
      );
    }

    hiCanvas.drawCircle(
      hiCenter,
      (outlineColor != null && outlineWidth > 0 ? fillRadiusWithOutline : fillRadius) *
          supersample,
      Paint()..color = color,
    );

    final hiImage = await hiRecorder
        .endRecording()
        .toImage(hiSize.toInt(), hiSize.toInt());

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      hiImage,
      Rect.fromLTWH(0, 0, hiSize, hiSize),
      const Rect.fromLTWH(0, 0, size, size),
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final data = bytes?.buffer.asUint8List() ?? Uint8List(0);
    return BitmapDescriptor.bytes(data);
  }

  @override
  void didUpdateWidget(covariant RideMapSnippet oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = oldWidget.pickupLat != widget.pickupLat ||
        oldWidget.pickupLng != widget.pickupLng ||
        oldWidget.destinationLat != widget.destinationLat ||
        oldWidget.destinationLng != widget.destinationLng;
    if (changed) {
      _loadRouteDetails();
    }
  }

  Future<void> _loadRouteDetails() async {
    if (!_hasRouteCoords) return;

    setState(() {
      _isLoadingRoute = true;
      _routeDetails = null;
      _polylineLatLng = const [];
    });

    final details = await _locationService.getDirectionsByCoords(
      originLat: widget.pickupLat!,
      originLng: widget.pickupLng!,
      destinationLat: widget.destinationLat!,
      destinationLng: widget.destinationLng!,
      originName: widget.pickupLabel,
      destinationName: widget.destinationLabel,
    );

    if (!mounted) return;

    final polylinePoints = <LatLng>[];
    if (details != null && details.polylinePoints.isNotEmpty) {
      polylinePoints.addAll(_decodePolyline(details.polylinePoints));
    }

    setState(() {
      _routeDetails = details;
      _polylineLatLng = polylinePoints;
      _isLoadingRoute = false;
    });
  }

  LatLngBounds _buildBounds() {
    final points = <LatLng>[
      LatLng(widget.pickupLat!, widget.pickupLng!),
      LatLng(widget.destinationLat!, widget.destinationLng!),
    ];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points.skip(1)) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    const epsilon = 0.001;
    if ((maxLat - minLat).abs() < epsilon) {
      maxLat += epsilon;
      minLat -= epsilon;
    }
    if ((maxLng - minLng).abs() < epsilon) {
      maxLng += epsilon;
      minLng -= epsilon;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.pickupLat!, widget.pickupLng!),
        infoWindow: InfoWindow(title: widget.pickupLabel),
        icon: _pickupMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        onTap: () => _showPointActions(
          label: widget.pickupLabel,
          lat: widget.pickupLat!,
          lng: widget.pickupLng!,
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destinationLat!, widget.destinationLng!),
        infoWindow: InfoWindow(title: widget.destinationLabel),
        icon: _destinationMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(0.5, 0.5),
        onTap: () => _showPointActions(
          label: widget.destinationLabel,
          lat: widget.destinationLat!,
          lng: widget.destinationLng!,
        ),
      ),
    };

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_polylineLatLng.length < 2) return const <Polyline>{};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _polylineLatLng,
        width: 5,
        color: AppColors.routeEndBlue,
        geodesic: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    if (!_hasRouteCoords) {
      return _buildFallbackPreview(context, colors);
    }

    if (kIsWeb) {
      return _buildWebStaticMap(context, colors);
    }

    final midpoint = LatLng(
      (widget.pickupLat! + widget.destinationLat!) / 2,
      (widget.pickupLng! + widget.destinationLng!) / 2,
    );

    return GlassBox(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: midpoint, zoom: 12),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: false,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                markers: _buildMarkers(),
                polylines: _buildPolylines(),
                style: Theme.of(context).brightness == Brightness.dark
                    ? AppMapStyles.darkMapStyle
                    : AppMapStyles.lightMapStyle,
                onMapCreated: (controller) async {
                  _controller = controller;
                  try {
                    await controller.animateCamera(
                      CameraUpdate.newLatLngBounds(_buildBounds(), 48),
                    );
                  } catch (_) {
                    // Ignore transient camera-fit errors on first layout frame.
                  }
                },
              ),
              Positioned(
                left: 12,
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: _chip(
                        context,
                        icon: Icons.trip_origin_rounded,
                        text: widget.pickupLabel,
                        onTap: () => _showPointActions(
                          label: widget.pickupLabel,
                          lat: widget.pickupLat!,
                          lng: widget.pickupLng!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _chip(
                        context,
                        icon: Icons.flag_rounded,
                        text: widget.destinationLabel,
                        onTap: () => _showPointActions(
                          label: widget.destinationLabel,
                          lat: widget.destinationLat!,
                          lng: widget.destinationLng!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_routeDetails != null)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _statsPill(context),
                )
              else if (_isLoadingRoute)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _loadingPill(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackPreview(BuildContext context, GermanaColors colors) {
    return GlassBox(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: widget.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.accentBlue),
                const SizedBox(width: 8),
                Text('Route preview', style: AppTextStyles.captionBold(context)),
              ],
            ),
            const SizedBox(height: 14),
            _routePoint(
              context,
              dotColor: AppColors.routeStartBlue,
              label: widget.pickupLabel,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                width: 2,
                height: 32,
                color: colors.textTertiary.withValues(alpha: 0.35),
              ),
            ),
            _routePoint(
              context,
              dotColor: colors.isDark
                  ? AppColors.routeEndNeutralDark
                  : AppColors.routeEndNeutralLight,
              label: widget.destinationLabel,
            ),
            const Spacer(),
            if (_isLoadingRoute)
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading route...',
                    style: AppTextStyles.caption(context),
                  ),
                ],
              )
            else if (_routeDetails != null)
              _statsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWebStaticMap(BuildContext context, GermanaColors colors) {
    if (_webStaticMapsBlockedForSession) {
      return _buildFallbackPreview(context, colors);
    }

    final staticUrl = _buildStaticMapUrl(context);
    if (staticUrl == null) {
      return _buildFallbackPreview(context, colors);
    }

    return GlassBox(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                staticUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  _webStaticMapsBlockedForSession = true;
                  return Container(
                    color: colors.glassSurface,
                  );
                },
              ),
              if (Theme.of(context).brightness == Brightness.dark)
                Container(color: Colors.black.withValues(alpha: 0.22)),
              Positioned(
                left: 12,
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: _chip(
                        context,
                        icon: Icons.trip_origin_rounded,
                        text: widget.pickupLabel,
                        onTap: () => _showPointActions(
                          label: widget.pickupLabel,
                          lat: widget.pickupLat!,
                          lng: widget.pickupLng!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _chip(
                        context,
                        icon: Icons.flag_rounded,
                        text: widget.destinationLabel,
                        onTap: () => _showPointActions(
                          label: widget.destinationLabel,
                          lat: widget.destinationLat!,
                          lng: widget.destinationLng!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_routeDetails != null)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _statsPill(context),
                )
              else if (_isLoadingRoute)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _loadingPill(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _buildStaticMapUrl(BuildContext context) {
    final apiKey = AppConfig.googleMapsApiKey;
    if (apiKey.isEmpty || !_hasRouteCoords) return null;

    String toHex(Color c) {
      final rgb = c.value & 0x00FFFFFF;
      return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
    }

    final startHex = toHex(AppColors.routeStartBlue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final endHex = toHex(
      isDark ? AppColors.routeEndNeutralDark : AppColors.routeEndNeutralLight,
    );

    final query = <String>[
      'size=1200x700',
      'scale=2',
      'maptype=roadmap',
      'key=${Uri.encodeQueryComponent(apiKey)}',
      'markers=${Uri.encodeQueryComponent('color:0x$startHex|label:P|${widget.pickupLat},${widget.pickupLng}')}',
      'markers=${Uri.encodeQueryComponent('color:0x$endHex|label:D|${widget.destinationLat},${widget.destinationLng}')}',
    ];

    if (_routeDetails != null && _routeDetails!.polylinePoints.isNotEmpty) {
      query.add(
        'path=${Uri.encodeQueryComponent('weight:5|color:0x1A73E8FF|enc:${_routeDetails!.polylinePoints}')}',
      );
    }

    if (Theme.of(context).brightness == Brightness.dark) {
      final darkStyles = <String>[
        'feature:all|element:geometry|color:0x1f2937',
        'feature:all|element:labels.text.fill|color:0xe5e7eb',
        'feature:all|element:labels.text.stroke|color:0x111827',
        'feature:road|element:geometry|color:0x374151',
        'feature:water|element:geometry|color:0x0f172a',
      ];
      for (final style in darkStyles) {
        query.add('style=${Uri.encodeQueryComponent(style)}');
      }
    }

    return 'https://maps.googleapis.com/maps/api/staticmap?${query.join('&')}';
  }

  Widget _statsRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.route_rounded, size: 14, color: AppColors.accentBlue),
        const SizedBox(width: 6),
        Text(
          '${_routeDetails!.distanceKm.toStringAsFixed(1)} km',
          style: AppTextStyles.captionBold(context),
        ),
        const SizedBox(width: 10),
        Icon(Icons.schedule_rounded, size: 14, color: AppColors.accentBlue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _routeDetails!.durationText,
            style: AppTextStyles.captionBold(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statsPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.route_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            '${_routeDetails!.distanceKm.toStringAsFixed(1)} km',
            style: AppTextStyles.caption(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            _routeDetails!.durationText,
            style: AppTextStyles.caption(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Fetching route',
            style: AppTextStyles.caption(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routePoint(
    BuildContext context, {
    required Color dotColor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.title(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 12, color: Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPointActions({
    required String label,
    required double lat,
    required double lng,
  }) async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colors = GermanaColors.of(context);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GlassBox(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.headline(context)),
                  const SizedBox(height: 8),
                  Text(
                    'Choose map action',
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.streetview_rounded),
                    title: const Text('Street View'),
                    trailing: Icon(Icons.open_in_new_rounded, color: colors.textTertiary),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _openStreetView(label: label, lat: lat, lng: lng);
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.map_rounded),
                    title: const Text('Open in Maps'),
                    trailing: Icon(Icons.open_in_new_rounded, color: colors.textTertiary),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _openMaps(lat: lat, lng: lng);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openStreetView({
    required String label,
    required double lat,
    required double lng,
  }) async {
    if (!kIsWeb) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StreetViewScreen(
            label: label,
            lat: lat,
            lng: lng,
          ),
        ),
      );
      return;
    }

    final webUri = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$lat,$lng',
    );
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMaps({required double lat, required double lng}) async {
    final appUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
