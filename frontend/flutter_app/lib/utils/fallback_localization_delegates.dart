import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A custom [MaterialLocalizations] delegate that falls back to English
/// for locales not natively supported by Flutter (e.g., 'om' for Afan Oromo).
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Check if the locale is natively supported
    final isNativelySupported = GlobalMaterialLocalizations.delegate
        .isSupported(locale);
    
    if (isNativelySupported) {
      return GlobalMaterialLocalizations.delegate.load(locale);
    }
    // Fall back to English for unsupported locales
    return GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// A custom [CupertinoLocalizations] delegate that falls back to English
/// for locales not natively supported by Flutter (e.g., 'om' for Afan Oromo).
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    final isNativelySupported = GlobalCupertinoLocalizations.delegate
        .isSupported(locale);
    
    if (isNativelySupported) {
      return GlobalCupertinoLocalizations.delegate.load(locale);
    }
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
