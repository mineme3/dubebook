import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/fallback_localization_delegates.dart';
import 'l10n/app_localizations.dart';
import 'utils/theme.dart';
import 'screens/splash_setup_screen.dart';
import 'services/notification_service.dart';
import 'services/locale_service.dart';
import 'services/auth_provider.dart';
import 'services/theme_provider.dart';
import 'services/mongodb_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize SQLite notifications
  await NotificationService().init();
  await initializeDateFormatting('en_US', null);
  
  // Try establishing direct connection to MongoDB online asynchronously
  unawaited(MongoDbService.instance.connect());
  
  // Load saved locale
  final savedLocale = await LocaleService.getSavedLocale();
  
  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: DubeNoteApp(initialLocale: savedLocale),
    ),
  );
}

class DubeNoteApp extends StatefulWidget {
  final Locale? initialLocale;
  const DubeNoteApp({super.key, this.initialLocale});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_DubeNoteAppState>();
    state?.setLocale(locale);
  }

  @override
  State<DubeNoteApp> createState() => _DubeNoteAppState();
}

class _DubeNoteAppState extends State<DubeNoteApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Dube Book',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
      ],
      home: const SplashSetupScreen(),
    );
  }
}