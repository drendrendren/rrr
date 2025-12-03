import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrr/dogu/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding =
      prefs.getBool('seen_onboarding') ?? false; // 온보딩 봤는지 여부 bool로 가져옴

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko'),
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    final router = createRouter(seenOnboarding);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: const Locale('ko'),
    );
  }
}
