import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/dogu/palette.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TextSpan에 바로 .tr() 사용 불가능(context 문제)해서 미리 선언함
    final String errorDescription = 'error_screen_description'.tr();

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Palette.backgroundPrimary, Palette.backgroundSecondary],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: MediaQueryDogu.width(context) * 0.8,
            height: MediaQueryDogu.height(context) * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Palette.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    children: [
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.pets,
                          color: Palette.primary,
                          size: 15,
                        ),
                      ),
                      TextSpan(text: errorDescription),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: Text(
                    'error_screen_home_button_text'.tr(),
                    style: const TextStyle(
                      color: Palette.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
