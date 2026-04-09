import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:germana/core/ambient_background.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(GermanaApp());
}

class GermanaApp extends StatelessWidget {
  GermanaApp({super.key});

  final _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          // Update system UI based on theme
          final isDark = _appState.themeMode == ThemeMode.dark;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp(
            title: 'Germana',
            debugShowCheckedModeBanner: false,
            theme: buildGermanaLightTheme(),
            darkTheme: buildGermanaDarkTheme(),
            themeMode: _appState.themeMode,
            home: const AmbientBackground(
              child: AppShell(),
            ),
          );
        },
      ),
    );
  }
}
