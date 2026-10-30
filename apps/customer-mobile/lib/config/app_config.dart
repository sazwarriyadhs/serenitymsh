class AppConfig {
  static const String hotelName = 'IPB Convention Hotel';
  static const String platformName = 'SERENITY';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  static const String hotelLogo = 'assets/logo/iicc-logo-1.png';

  static const String heroImage = 'assets/images/ipbconvention.jpg';

  static const String lobbyImage = 'assets/images/hero-lobby.jpg';

  static const String weddingImage = 'assets/images/wedding.jpg';

  static const String conferenceImage = 'assets/images/confrence.jpg';
}
