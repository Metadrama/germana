import 'dart:convert';
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
  final _uuid = const Uuid();
  String _sessionToken = '';

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

  /// Get autocomplete suggestions limited to Malaysia (New Places API).
  Future<List<PlaceSuggestion>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

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
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('suggestions')) {
          return (data['suggestions'] as List)
              .map((p) => PlaceSuggestion.fromJson(p))
              .toList();
        }
      } else {
        print('Places API Status not 200: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('LocationService Exception: $e');
    }
    return [];
  }

  /// Get place details (specifically coordinates) from a place ID.
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Goog-Api-Key': AppConfig.googleMapsApiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
        },
      );

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
        print('Place Details Fetch Error: \${response.statusCode} - \${response.body}');
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  /// Get routing information between two points.
  Future<RouteDetails?> getDirections(PlaceDetails origin, PlaceDetails destination) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.lat},${origin.lng}'
        '&destination=${destination.lat},${destination.lng}'
        '&key=${AppConfig.googleMapsApiKey}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          return RouteDetails(
            distanceKm: leg['distance']['value'] / 1000.0, // convert meters to KM
            durationText: leg['duration']['text'],
            polylinePoints: route['overview_polyline']['points'],
          );
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
}
