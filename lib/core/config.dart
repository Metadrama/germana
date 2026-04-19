/// Secure configuration constants for Germana app.
class AppConfig {
  /// Google Cloud Platform API Key for Places, Maps, and Directions APIs.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
