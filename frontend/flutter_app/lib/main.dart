import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/fallback_localization_delegates.dart';
import 'l10n/app_localizations.dart';
import 'utils/theme.dart';
import 'core/router/app_router.dart';
import 'services/locale_service.dart';

Future<void> main() async {
  // Ensure Flutter widgets are completely initialized before anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env file may not exist in dev — defaults will be used
  }

  // Initialize date formatting
  await initializeDateFormatting('en_US', null);

  // Load saved locale preference
  final savedLocale = await LocaleService.getSavedLocale();

  runApp(
    ProviderScope(
      child: DubeNoteApp(initialLocale: savedLocale),
    ),
  );
}

class DubeNoteApp extends ConsumerStatefulWidget {
  final Locale? initialLocale;
  const DubeNoteApp({super.key, this.initialLocale});

  // Static method to change locale from anywhere in the app
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_DubeNoteAppState>();
    state?.setLocale(locale);
  }

  @override
  ConsumerState<DubeNoteApp> createState() => _DubeNoteAppState();
}

class _DubeNoteAppState extends ConsumerState<DubeNoteApp> {
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
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Dubebook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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
        Locale('so'),
      ],
      routerConfig: router,
    );
  }
}