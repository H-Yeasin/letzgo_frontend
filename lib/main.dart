import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LetzGoApp()));
}

class LetzGoApp extends ConsumerWidget {
  const LetzGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LetzGo',
      debugShowCheckedModeBanner: false,
      theme: defiLightTheme,
      darkTheme: defiDarkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
