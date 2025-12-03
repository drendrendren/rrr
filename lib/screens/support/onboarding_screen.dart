import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gradient_button/flutter_gradient_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rrr/dogu/palette.dart';
import 'package:rrr/dogu/media_query.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  final TextEditingController dogNameInputController = TextEditingController();
  final int onboardingPageNum = 4; // 온보딩 pageview 화면 수
  int currentPage = 0;

  // profile name(dog name) shared preferences 에 저장하는 함수
  Future<void> saveProfileName({required String pn}) async {
    if (pn.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileName', pn);
    }
  }

  // 온보딩 완료 여부를 저장하는 함수
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: completeOnboarding,
            child: const Text(
              '건너뛰기',
              style: TextStyle(
                color: Palette.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF472d10), Palette.primary],
            center: Alignment(0, 0),
            radius: 0.4,
            stops: [0.4, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQueryDogu.height(context) * 0.5,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemCount: onboardingPageNum,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'onboarding_screen_title${index + 1}'.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          color: Palette.textTertiary,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQueryDogu.width(context) / 25,
                        ),
                      ),
                      Text(
                        'onboarding_screen_description${index + 1}'.tr(),
                        style: TextStyle(
                          color: const Color(0xFFC0C0C0),
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQueryDogu.width(context) / 29,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child:
                            (index < 3)
                                ? SizedBox(
                                  height: MediaQueryDogu.height(context) * 0.3,
                                  child: Image.asset(
                                    'assets/images/onboarding/o${index + 1}.png',
                                    fit: BoxFit.contain,
                                  ),
                                )
                                : Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQueryDogu.height(context) * 0.07,
                                      child: Image.asset(
                                        'assets/images/onboarding/o4.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: SizedBox(
                                        width:
                                            MediaQueryDogu.width(context) * 0.4,
                                        height: 38,
                                        child: TextField(
                                          controller: dogNameInputController,
                                          keyboardType: TextInputType.text,
                                          maxLines: 1,
                                          decoration: InputDecoration(
                                            labelText:
                                                'onboarding_screen_dog_name_input_textfield_label_text'
                                                    .tr(),
                                            labelStyle: const TextStyle(
                                              color: Palette.textTertiary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            hintText: 'example_dog_name'.tr(),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFFC0C0C0),
                                            ),
                                            border: const OutlineInputBorder(),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Color(0xFFC0C0C0),
                                                    width: 1,
                                                  ),
                                                ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Color(0xFF808080),
                                                    width: 2,
                                                  ),
                                                ),
                                            counterStyle: const TextStyle(
                                              color: Color(0xFF808080),
                                            ),
                                          ),
                                          cursorColor: const Color(0xFF808080),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFFC0C0C0),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 인디케이터
                SmoothPageIndicator(
                  controller: pageController,
                  count: onboardingPageNum,
                  effect: const WormEffect(
                    dotHeight: 9,
                    dotWidth: 9,
                    spacing: 6,
                    dotColor: Color(0xFFE3E3E3),
                    activeDotColor: Palette.secondary,
                  ),
                ),
                // 시작하기 버튼
                (currentPage == onboardingPageNum - 1)
                    ? Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: SizedBox(
                        width: MediaQueryDogu.width(context) * 0.67,
                        child: GradientButton(
                          colors: const [Palette.tertiary, Palette.secondary],
                          height: 40,
                          width: MediaQueryDogu.width(context) * 0.55,
                          gradientDirection: GradientDirection.leftToRight,
                          text: 'onboarding_screen_start_button_text'.tr(),
                          textStyle: const TextStyle(
                            color: Palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: () async {
                            // profile name 저장한 후 onboarding 여부 저장함
                            await saveProfileName(
                              pn: dogNameInputController.text,
                            );
                            completeOnboarding();
                          },
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
