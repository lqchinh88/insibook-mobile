import 'en.dart';
import 'vi.dart';

class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'vi': vi,
  };

  final String locale;
  
  AppLocalizations(this.locale);

  String getText(String key) {
    return _localizedValues[locale]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }
  
  // Convenience getter for common use
  String operator [](String key) => getText(key);
}