/// Secure configuration constants for Germana app.
class AppConfig {
  /// Google Cloud Platform API Key for Places, Maps, and Directions APIs.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Optional remote JSON endpoint for Malaysia fuel prices.
  /// Expected keys: ron95, ron97, diesel, optional effectiveFrom.
  static const String malaysiaFuelPriceFeedUrl = String.fromEnvironment(
    'MALAYSIA_FUEL_PRICE_FEED_URL',
    defaultValue: '',
  );
}
