import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'data/local/hive_database.dart';
import 'di/injector.dart';
import 'presentation/blocs/home/home_bloc.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_event.dart';
import 'presentation/blocs/settings/settings_state.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize Hive
  await HiveDatabase.initialize();
  
  // Setup dependency injection
  await setupDependencies();
  
  // Initialize AdMob
  await getIt<AdService>().initialize();
  
  // Load interstitial ad
  getIt<AdService>().loadInterstitialAd();
  
  runApp(const ProScriptApp());
}

class ProScriptApp extends StatelessWidget {
  const ProScriptApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(LoadSettings()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isDarkMode = state is SettingsLoaded ? state.settings.isDarkMode : true;
          
          return MaterialApp(
            title: 'ProScript',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => getIt<HomeBloc>(),
                ),
              ],
              child: const HomeScreen(),
            ),
            routes: {
              '/settings': (context) => BlocProvider.value(
                value: context.read<SettingsBloc>(),
                child: const SettingsScreen(),
              ),
            },
          );
        },
      ),
    );
  }
}
