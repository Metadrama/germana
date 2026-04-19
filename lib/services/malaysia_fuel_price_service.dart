import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:germana/core/config.dart';
import 'package:http/http.dart' as http;

enum FuelType {
  ron95,
  ron97,
  diesel,
}

class FuelPriceSnapshot {
  final DateTime effectiveFrom;
  final double ron95;
  final double ron97;
  final double diesel;

  const FuelPriceSnapshot({
    required this.effectiveFrom,
    required this.ron95,
    required this.ron97,
    required this.diesel,
  });
}

class MalaysiaFuelPriceService {
  static const Duration _syncThrottle = Duration(hours: 6);
  static FuelPriceSnapshot? _remoteSnapshot;
  static DateTime? _lastRemoteSyncAt;
  static Future<void>? _inFlightSync;

  // Local snapshots for predictable pricing and offline UX.
  static final List<FuelPriceSnapshot> _history = <FuelPriceSnapshot>[
    FuelPriceSnapshot(
      effectiveFrom: DateTime(2025, 12, 1),
      ron95: 2.05,
      ron97: 3.47,
      diesel: 3.35,
    ),
    FuelPriceSnapshot(
      effectiveFrom: DateTime(2026, 1, 1),
      ron95: 2.05,
      ron97: 3.33,
      diesel: 3.33,
    ),
    FuelPriceSnapshot(
      effectiveFrom: DateTime(2026, 2, 1),
      ron95: 2.05,
      ron97: 3.28,
      diesel: 3.30,
    ),
    FuelPriceSnapshot(
      effectiveFrom: DateTime(2026, 3, 1),
      ron95: 2.05,
      ron97: 3.22,
      diesel: 3.28,
    ),
    FuelPriceSnapshot(
      effectiveFrom: DateTime(2026, 4, 1),
      ron95: 2.05,
      ron97: 3.18,
      diesel: 3.26,
    ),
  ];

  Future<void> syncFromRemoteIfConfigured({bool force = false}) async {
    final feedUrl = AppConfig.malaysiaFuelPriceFeedUrl.trim();
    if (feedUrl.isEmpty) return;

    final now = DateTime.now();
    if (!force && _lastRemoteSyncAt != null) {
      final age = now.difference(_lastRemoteSyncAt!);
      if (age < _syncThrottle) return;
    }

    if (_inFlightSync != null) {
      await _inFlightSync;
      return;
    }

    _inFlightSync = _syncFromRemote(feedUrl);
    try {
      await _inFlightSync;
    } finally {
      _inFlightSync = null;
    }
  }

  Future<void> _syncFromRemote(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 7));

      if (response.statusCode != 200) {
        debugPrint('Fuel feed status: ${response.statusCode}');
        return;
      }

      final parsed = json.decode(response.body);
      final snapshot = _tryParseSnapshot(parsed);
      if (snapshot == null) {
        debugPrint('Fuel feed parse failed; using local snapshot fallback.');
        return;
      }

      _remoteSnapshot = snapshot;
      _lastRemoteSyncAt = DateTime.now();
    } on TimeoutException {
      debugPrint('Fuel feed timeout; using local snapshot fallback.');
    } catch (e) {
      debugPrint('Fuel feed sync error: $e');
    }
  }

  FuelPriceSnapshot? _tryParseSnapshot(dynamic payload) {
    final map = _extractMap(payload);
    if (map == null) return null;

    final effectiveRaw = map['effectiveFrom'] ?? map['effective_from'];
    DateTime effectiveFrom;
    if (effectiveRaw is String && effectiveRaw.isNotEmpty) {
      effectiveFrom = DateTime.tryParse(effectiveRaw) ?? DateTime.now();
    } else {
      effectiveFrom = DateTime.now();
    }

    final ron95 = _asDouble(map['ron95']);
    final ron97 = _asDouble(map['ron97']);
    final diesel = _asDouble(map['diesel']);

    if (ron95 == null || ron97 == null || diesel == null) return null;

    return FuelPriceSnapshot(
      effectiveFrom: effectiveFrom,
      ron95: ron95,
      ron97: ron97,
      diesel: diesel,
    );
  }

  Map<String, dynamic>? _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (payload.containsKey('ron95') ||
          payload.containsKey('ron97') ||
          payload.containsKey('diesel')) {
        return payload;
      }

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  FuelPriceSnapshot currentSnapshot({DateTime? now}) {
    if (_remoteSnapshot != null) return _remoteSnapshot!;

    final ref = (now ?? DateTime.now());
    FuelPriceSnapshot best = _history.first;
    for (final item in _history) {
      if (!item.effectiveFrom.isAfter(ref)) {
        best = item;
      }
    }
    return best;
  }

  double currentPrice(FuelType fuelType, {DateTime? now}) {
    final snapshot = currentSnapshot(now: now);
    switch (fuelType) {
      case FuelType.ron95:
        return snapshot.ron95;
      case FuelType.ron97:
        return snapshot.ron97;
      case FuelType.diesel:
        return snapshot.diesel;
    }
  }

  String label(FuelType fuelType) {
    switch (fuelType) {
      case FuelType.ron95:
        return 'RON95';
      case FuelType.ron97:
        return 'RON97';
      case FuelType.diesel:
        return 'Diesel';
    }
  }

  String trendLabel(FuelType fuelType, {DateTime? now}) {
    final snapshot = currentSnapshot(now: now);
    final idx = _history.indexOf(snapshot);
    if (idx <= 0) return 'stable';

    final prev = _history[idx - 1];
    final current = currentPrice(fuelType, now: now);
    final before = _priceForSnapshot(prev, fuelType);

    if (current > before) return 'up';
    if (current < before) return 'down';
    return 'stable';
  }

  DateTime lastUpdated({DateTime? now}) => currentSnapshot(now: now).effectiveFrom;

  double _priceForSnapshot(FuelPriceSnapshot snapshot, FuelType fuelType) {
    switch (fuelType) {
      case FuelType.ron95:
        return snapshot.ron95;
      case FuelType.ron97:
        return snapshot.ron97;
      case FuelType.diesel:
        return snapshot.diesel;
    }
  }
}
