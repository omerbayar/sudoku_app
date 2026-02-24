import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization? _instance;
  static AppLocalization get instance => _instance!;

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    _instance = this;
    return true;
  }

  String get(String key, [Map<String, String>? params]) {
    var value = _localizedStrings[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  static List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('tr'),
  ];
}

/// Top-level translate function — use anywhere: Text(translate("sudoku"))
String translate(String key, [Map<String, String>? params]) {
  return AppLocalization.instance.get(key, params);
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) async {
    final localization = AppLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
