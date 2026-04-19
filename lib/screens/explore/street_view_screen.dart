import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:germana/core/config.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StreetViewScreen extends StatefulWidget {
  final String label;
  final double lat;
  final double lng;

  const StreetViewScreen({
    super.key,
    required this.label,
    required this.lat,
    required this.lng,
  });

  @override
  State<StreetViewScreen> createState() => _StreetViewScreenState();
}

class _StreetViewScreenState extends State<StreetViewScreen> {
  late final WebViewController _controller;
  bool _isFullscreen = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            // Ignore subresource failures; treat only main-frame failure as fatal.
            if (error.isForMainFrame ?? true) {
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'Street View failed to load in-app for this point.';
              });
            }
          },
        ),
      );

    _loadNearestStreetView();
  }

  Future<void> _loadNearestStreetView() async {
    final resolved = await _resolveNearestPano();
    if (!mounted) return;

    if (resolved == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            _errorMessage ?? 'Street View is not available near this point.';
      });
      return;
    }

    final apiKey = AppConfig.googleMapsApiKey;
    if (apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Street View unavailable: missing API key.';
      });
      return;
    }

    final embedUrl =
        'https://www.google.com/maps/embed/v1/streetview?key=$apiKey&location=${resolved.latitude},${resolved.longitude}&source=outdoor';

    final html = '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
    <style>
      html, body { margin: 0; padding: 0; width: 100%; height: 100%; background: #000; }
      iframe { border: 0; width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <iframe
      allowfullscreen
      loading="eager"
      referrerpolicy="no-referrer-when-downgrade"
      src="$embedUrl">
    </iframe>
  </body>
</html>
''';

    await _controller.loadHtmlString(html);
  }

  Future<_LatLng?> _resolveNearestPano() async {
    final apiKey = AppConfig.googleMapsApiKey;
    if (apiKey.isEmpty) {
      _errorMessage = 'Street View unavailable: missing API key.';
      return null;
    }

    const radii = <int>[50, 120, 250, 500, 1000];
    for (final radius in radii) {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/streetview/metadata'
        '?location=${widget.lat},${widget.lng}'
        '&radius=$radius'
        '&source=outdoor'
        '&key=$apiKey',
      );

      try {
        final response = await http.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) {
          _errorMessage =
              'Street View metadata failed (${response.statusCode}).';
          continue;
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'UNKNOWN';

        if (status == 'OK') {
          final location = data['location'] as Map<String, dynamic>?;
          final lat = (location?['lat'] as num?)?.toDouble();
          final lng = (location?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) return _LatLng(lat, lng);
        }

        if (status == 'REQUEST_DENIED') {
          _errorMessage =
              'Street View denied by API key restrictions.';
          return null;
        }
        if (status == 'OVER_QUERY_LIMIT') {
          _errorMessage = 'Street View quota exceeded.';
          return null;
        }
        if (status == 'INVALID_REQUEST') {
          _errorMessage = 'Street View request invalid for this location.';
          return null;
        }
        // ZERO_RESULTS -> try a wider radius.
      } on TimeoutException {
        _errorMessage = 'Street View metadata request timed out.';
      } catch (_) {
        _errorMessage = 'Street View metadata request failed.';
      }
    }

    return null;
  }

  Future<void> _openExternalStreetView() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${widget.lat},${widget.lng}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text('Street View · ${widget.label}'),
              actions: [
                IconButton(
                  onPressed: () => setState(() => _isFullscreen = true),
                  icon: const Icon(Icons.fullscreen_rounded),
                  tooltip: 'Fullscreen',
                ),
              ],
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _openExternalStreetView,
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('Open in Google Maps'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : WebViewWidget(controller: _controller),
          ),
          if (_isFullscreen)
            Positioned(
              top: 12,
              left: 12,
              child: SafeArea(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => setState(() => _isFullscreen = false),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.fullscreen_exit_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LatLng {
  final double latitude;
  final double longitude;

  const _LatLng(this.latitude, this.longitude);
}
