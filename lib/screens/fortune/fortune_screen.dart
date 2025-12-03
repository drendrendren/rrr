import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rrr/dogu/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/widgets/screen/fortune_screen/space_background_widget.dart';

class FortuneScreen extends StatefulWidget {
  const FortuneScreen({super.key});

  @override
  State<FortuneScreen> createState() => _FortuneScreenState();
}

class _FortuneScreenState extends State<FortuneScreen> {
  final PageController fortuneThemePageController = PageController(
    viewportFraction: 0.33,
  );
  int currentFortuneThemePage = 0;

  final List<Map<String, dynamic>> fortuneThemeMap = [
    {
      "key": "all",
      "name": "🐕 전체",
      "subtitle": "랜덤 테마로 확인멍!",
      "image_name": "basic_dog",
    },
    {
      "key": "love",
      "name": "💘 연애",
      "subtitle": "그 사람과 잘될까멍?",
      "image_name": "love_dog",
    },
    {
      "key": "luck",
      "name": "🍀 행운",
      "subtitle": "럭키 지수 체크멍!",
      "image_name": "luck_dog",
    },
    {
      "key": "success",
      "name": "📈 성공",
      "subtitle": "일 잘 풀릴까멍?",
      "image_name": "success_dog",
    },
    {
      "key": "health",
      "name": "⚡ 건강",
      "subtitle": "컨디션 확인멍!",
      "image_name": "health_dog",
    },
  ];

  // 오늘 운세 봤는지 확인 후 => 페이지 이동하는 함수
  Future<void> isTodayFortune() async {
    final prefs = await SharedPreferences.getInstance();

    // 오늘 날짜
    final today = DateTime.now();
    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final savedDate = prefs.getString("saved_date");
    final savedFortune = prefs.getString("saved_fortune");
    final savedFortuneDescription = prefs.getString(
      "saved_fortune_description",
    );
    final savedTheme = prefs.getString("saved_theme");

    if (savedDate == todayKey &&
        savedTheme != null &&
        savedFortune != null &&
        savedFortuneDescription != null) {
      // 오늘 이미 뽑음
      context.go(
        '/fortuneResult?ftt=$savedTheme&ft=$savedFortune&ftd=$savedFortuneDescription',
      );
    } else {
      final String selectedFortuneTheme =
          fortuneThemeMap[currentFortuneThemePage]['key'];
      context.go('/fortuneLoading?sft=$selectedFortuneTheme');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Palette.iconTertiary),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: SpaceBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            '오늘의 운세를 확인해 보라멍!',
                            speed: const Duration(milliseconds: 130),
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                              color: Color(0xFFC0C0C0),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                        totalRepeatCount: 1,
                        repeatForever: false,
                        isRepeatingAnimation: false,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height:
                            (MediaQuery.of(context).size.width >= 290)
                                ? MediaQueryDogu.height(context) * 0.37
                                : MediaQueryDogu.height(context) * 0.47,
                        child: PageView.builder(
                          controller: fortuneThemePageController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: fortuneThemeMap.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentFortuneThemePage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final fortuneTheme = fortuneThemeMap[index];
                            final isActive = index == currentFortuneThemePage;

                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 700),
                              opacity: isActive ? 1 : 0.15,
                              curve: Curves.easeInOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 900),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        fortuneTheme['name'],
                                        style: TextStyle(
                                          color: const Color(0xFFC0C0C0),
                                          fontWeight:
                                              isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.w400,
                                          fontSize: isActive ? 11 : 9,
                                        ),
                                      ),
                                      subtitle: Text(
                                        fortuneTheme['subtitle'],
                                        style: TextStyle(
                                          color: const Color(0xFFC0C0C0),
                                          fontWeight:
                                              isActive
                                                  ? FontWeight.w500
                                                  : FontWeight.w300,
                                          fontSize: isActive ? 10 : 7,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          isActive
                                              ? MediaQueryDogu.height(context) *
                                                  0.2
                                              : MediaQueryDogu.height(context) *
                                                  0.065,
                                      child: Image.asset(
                                        'assets/images/character/${fortuneTheme['image_name']}.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        isTodayFortune();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        elevation: 4.0,
                        shadowColor: const Color(0xFF311B92).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        '오늘의 운세 보기',
                        style: TextStyle(
                          color: Color(0xFFE0E0E0),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '하루 1회만 가능하다멍!\n다른 친구들도 기다린다멍!',
                      style: TextStyle(
                        color: Color(0xFFC0C0C0),
                        fontWeight: FontWeight.w300,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
