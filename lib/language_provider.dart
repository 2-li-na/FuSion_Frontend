import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('de'); // Default to German
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  void _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  void changeLanguage(Locale newLocale) async {
    if (_currentLocale == newLocale) return;
    
    _currentLocale = newLocale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    notifyListeners();
  }
  
  void changeToGerman() => changeLanguage(const Locale('de'));
  void changeToEnglish() => changeLanguage(const Locale('en'));
}