enum Environment {
  dev,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.dev;

  static Environment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  static Environment fromString(String? envString) {
    if (envString == null || envString.isEmpty) {
      return Environment.dev; // Default to dev
    }

    switch (envString.toLowerCase()) {
      case 'dev':
      case 'development':
        return Environment.dev;
      case 'staging':
        return Environment.staging;
      case 'prod':
      case 'production':
        return Environment.production;
      default:
        return Environment.dev; // Default fallback
    }
  }

  static void initialize() {
    const String envString = String.fromEnvironment('ENVIRONMENT');
    _currentEnvironment = fromString(envString.isNotEmpty ? envString : null);
  }

  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  static bool get isDevelopment => _currentEnvironment == Environment.dev;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;
}