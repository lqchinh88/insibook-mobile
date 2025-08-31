import 'environment.dart';

class AppConfig {
  static const String _devApiBaseUrl = 'http://localhost:3000';
  static const String _stagingApiBaseUrl = 'https://staging-api.insibook.com';
  static const String _productionApiBaseUrl =
      'https://insibook-be-198695308977.asia-southeast1.run.app';

  static String get apiBaseUrl {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.dev:
        return _devApiBaseUrl;
      case Environment.staging:
        return _stagingApiBaseUrl;
      case Environment.production:
        return _productionApiBaseUrl;
    }
  }

  static String get appName {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.dev:
        return 'InsiBook Dev';
      case Environment.staging:
        return 'InsiBook Staging';
      case Environment.production:
        return 'InsiBook';
    }
  }

  static String get appSuffix {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.dev:
        return '.dev';
      case Environment.staging:
        return '.staging';
      case Environment.production:
        return '';
    }
  }

  static bool get showEnvironmentBanner {
    return !EnvironmentConfig.isProduction;
  }

  static bool get enableDebugFeatures {
    return EnvironmentConfig.isDevelopment;
  }

  static bool get enableLogging {
    return !EnvironmentConfig.isProduction;
  }

  static String get environmentDisplayName {
    return EnvironmentConfig.environmentName;
  }

  static Map<String, dynamic> get debugInfo {
    return {
      'environment': EnvironmentConfig.environmentName,
      'apiBaseUrl': apiBaseUrl,
      'appName': appName,
      'showBanner': showEnvironmentBanner,
      'debugFeatures': enableDebugFeatures,
      'logging': enableLogging,
    };
  }
}
