import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:germana/core/config.dart';

class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('placePrediction')) {
      final prediction = json['placePrediction'];
      final structured = prediction['structuredFormat'];
      return PlaceSuggestion(
        placeId: prediction['placeId'],
        mainText: structured?['mainText']?['text'] ?? prediction['text']?['text'] ?? '',
        secondaryText: structured?['secondaryText']?['text'] ?? '',
      );
    }
    // Fallback for unexpected formats
    return PlaceSuggestion(placeId: '', mainText: 'Unknown', secondaryText: '');
  }
}

class PlaceDetails {
  final double lat;
  final double lng;
  final String name;
  final String address;

  PlaceDetails({
    required this.lat,
    required this.lng,
    required this.name,
    required this.address,
  });
}

class RouteDetails {
  final double distanceKm; // Kilometers
  final String durationText;
  final String polylinePoints;

  RouteDetails({
    required this.distanceKm,
    required this.durationText,
    required this.polylinePoints,
  });
}

class LocationService {
  static const Duration _httpTimeout = Duration(seconds: 8);
  static const int _directionsMaxAttempts = 2;
  static bool _webDirectionsFallbackLogged = false;

  final _uuid = const Uuid();
  String _sessionToken = '';
  static bool _placesApiDisabled = false;
  static final Map<String, RouteDetails> _routeCache = <String, RouteDetails>{};

  // Initialize/refresh session token
  void refreshSessionToken() {
    _sessionToken = _uuid.v4();
  }

  String get currentSessionToken {
    if (_sessionToken.isEmpty) {
      refreshSessionToken();
    }
    return _sessionToken;
  }

  bool get isPlacesApiDisabled => _placesApiDisabled;

  String _routeCacheKey(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) {
    String fmt(double v) => v.toStringAsFixed(5);
    return '${fmt(originLat)},${fmt(originLng)}->${fmt(destinationLat)},${fmt(destinationLng)}';
  }

  /// Get autocomplete suggestions limited to Malaysia (New Places API).
  Future<List<PlaceSuggestion>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    if (_placesApiDisabled) return [];
    if (AppConfig.googleMapsApiKey.isEmpty) {
      _placesApiDisabled = true;
      return [];
    }

    final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
    final body = json.encode({
      'input': query,
      'includedRegionCodes': ['my'],
      'sessionToken': currentSessionToken
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': AppConfig.googleMapsApiKey,
        },
        body: body,
      ).timeout(_httpTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('suggestions')) {
          return (data['suggestions'] as List)
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        }
      } else {
        if (response.statusCode == 400 &&
            (response.body.contains('API_KEY_INVALID') ||
                response.body.contains('API key expired'))) {
          _placesApiDisabled = true;
          return [];
        }
        debugPrint('Places API Status not 200: ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('LocationService: autocomplete request timed out');
    } catch (e) {
      debugPrint('LocationService Exception: $e');
    }
    return [];
  }

  /// Get place details (specifically coordinates) from a place ID.
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (_placesApiDisabled) return null;
    if (AppConfig.googleMapsApiKey.isEmpty) {
      _placesApiDisabled = true;
      return null;
    }
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Goog-Api-Key': AppConfig.googleMapsApiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
        },
      ).timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['location'];
        
        // Token consumed, refresh for next search
        refreshSessionToken();

        return PlaceDetails(
          lat: location['latitude'] ?? 0.0,
          lng: location['longitude'] ?? 0.0,
          name: data['displayName']?['text'] ?? '',
          address: data['formattedAddress'] ?? '',
        );
      } else {
        if (response.statusCode == 400 &&
            (response.body.contains('API_KEY_INVALID') ||
                response.body.contains('API key expired'))) {
          _placesApiDisabled = true;
          return null;
        }
        debugPrint('Place Details Fetch Error: ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('LocationService: place details request timed out');
    } catch (e) {
      debugPrint('Place Details Exception: $e');
    }
    return null;
  }

  /// Get routing information between two points.
  Future<RouteDetails?> getDirections(PlaceDetails origin, PlaceDetails destination) async {
    final cacheKey = _routeCacheKey(
      origin.lat,
      origin.lng,
      destination.lat,
      destination.lng,
    );
    final cached = _routeCache[cacheKey];
    if (cached != null) return cached;

    if (kIsWeb) {
      // Browser clients cannot call Directions endpoint directly due to CORS.
      if (!_webDirectionsFallbackLogged) {
        _webDirectionsFallbackLogged = true;
        debugPrint('Directions API is not called on web (CORS). Using local estimate.');
      }
      final estimate = _buildEstimatedRoute(origin, destination);
      _routeCache[cacheKey] = estimate;
      return estimate;
    }

    if (AppConfig.googleMapsApiKey.isEmpty) return null;
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.lat},${origin.lng}'
        '&destination=${destination.lat},${destination.lng}'
        '&key=${AppConfig.googleMapsApiKey}');

    for (var attempt = 1; attempt <= _directionsMaxAttempts; attempt++) {
      try {
        final response = await http.get(url).timeout(_httpTimeout);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final route = data['routes'][0];
            final leg = route['legs'][0];

            final details = RouteDetails(
              distanceKm: leg['distance']['value'] / 1000.0, // convert meters to KM
              durationText: leg['duration']['text'],
              polylinePoints: route['overview_polyline']['points'],
            );
            _routeCache[cacheKey] = details;
            return details;
          }

          // API-level failure should not be retried blindly.
          debugPrint('Directions API returned status: ${data['status']}');
          return null;
        }

        // Retry on transient server-side failures.
        if (response.statusCode >= 500 && attempt < _directionsMaxAttempts) {
          continue;
        }
        debugPrint('Directions HTTP error: ${response.statusCode}');
        return null;
      } on TimeoutException {
        if (attempt >= _directionsMaxAttempts) {
          debugPrint('Directions request timed out after $attempt attempts');
        }
      } catch (e) {
        debugPrint('Directions request error: $e');
        if (attempt >= _directionsMaxAttempts) return null;
      }
    }

    return null;
  }

  RouteDetails _buildEstimatedRoute(PlaceDetails origin, PlaceDetails destination) {
    final distanceKm = _haversineKm(
      origin.lat,
      origin.lng,
      destination.lat,
      destination.lng,
    );

    // Conservative city/intercity blended speed for UX estimate.
    const avgSpeedKmh = 40.0;
    final durationMinutes = (distanceKm / avgSpeedKmh * 60).clamp(1, 24 * 60).round();

    return RouteDetails(
      distanceKm: distanceKm,
      durationText: _formatDuration(durationMinutes),
      polylinePoints: '',
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            (math.sin(dLon / 2) * math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes} min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  Future<RouteDetails?> getDirectionsByCoords({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    String originName = 'Origin',
    String destinationName = 'Destination',
  }) {
    return getDirections(
      PlaceDetails(
        lat: originLat,
        lng: originLng,
        name: originName,
        address: originName,
      ),
      PlaceDetails(
        lat: destinationLat,
        lng: destinationLng,
        name: destinationName,
        address: destinationName,
      ),
    );
  }
}
