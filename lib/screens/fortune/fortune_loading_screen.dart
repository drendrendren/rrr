import 'dart:math';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/widgets/screen/fortune_screen/space_background_widget.dart';

class FortuneLoadingScreen extends StatefulWidget {
  final String selectedFortuneTheme;

  const FortuneLoadingScreen({super.key, required this.selectedFortuneTheme});

  @override
  State<FortuneLoadingScreen> createState() => _FortuneLoadingScreenState();
}

class _FortuneLoadingScreenState extends State<FortuneLoadingScreen> {
  String selectedFortuneTheme = '';

  @override
  void initState() {
    super.initState();
    selectedFortuneTheme = widget.selectedFortuneTheme;
    loadFortune(sft: selectedFortuneTheme);
    loadingMessage = getRandomLoadingMessage();
  }

  late String loadingMessage = '';

  final List<String> loadingMessageList = [
    "별빛들의 기운을 모으고 있다멍.. ✨",
    "행운의 카드를 섞고 있다멍.. 🃏",
    "오늘의 운세를 찾는 중이다멍.. 🍀",
    "우주의 기운을 불러오고 있다멍.. 🌌",
    "마법 주문을 준비하고 있다멍.. 🔮",
    "너의 기운을 살피고 있다멍.. 🌙",
    "운명의 실마리를 풀고 있다멍.. 🧵",
    "나 마법 강아지가 집중하고 있다멍.. 🐱‍👓",
    "오늘의 길을 읽고 있다멍.. 🚪",
    "별자리를 이어보고 있다멍.. ⭐",
    "달빛 속에서 답을 찾고 있다멍.. 🌙",
    "별들의 속삭임을 듣고 있다멍.. ✨",
    "시간의 흐름을 헤아리고 있다멍.. ⏳",
    "마법서의 페이지를 펼치고 있다멍.. 📖",
    "운세 조각을 모으고 있다멍.. 🧩",
    "행운의 향기를 따라가고 있다멍.. 🌸",
    "내 수염이 살짝 떨리고 있다멍.. 🐾",
    "오늘의 별빛을 담아내고 있다멍.. 🌟",
    "운명의 나침반을 맞추고 있다멍.. 🧭",
    "마법의 물약을 섞고 있다멍.. 🧪",
    "나 마법 강아지가 준비하고 있다멍.. 🐱",
    "행운의 문을 두드리고 있다멍.. 🚪",
    "운명의 카드를 고르고 있다멍.. 🃏",
    "별빛 길을 따라가고 있다멍.. 🌌",
    "마법의 힘을 모으고 있다멍.. ✨",
    "오늘의 기운을 불러오고 있다멍.. 🌠",
    "비밀스러운 주문을 속삭이고 있다멍.. 🔮",
    "너만의 길을 열고 있다멍.. 🌈",
    "행운의 씨앗을 심고 있다멍.. 🌱",
  ];
  final Map<String, String> fortuneThemeMap = {
    "love": "연애",
    "luck": "행운",
    "success": "성공",
    "health": "건강",
  };

  // 랜덤하게 loading message 뽑는 함수
  String getRandomLoadingMessage() {
    final random = Random();
    return loadingMessageList[random.nextInt(loadingMessageList.length)];
  }

  // 랜덤하게 운세 뽑는 함수
  Future<void> loadFortune({required String sft}) async {
    String fortuneTheme = '';

    final random = Random();
    if (sft == 'all') {
      // fortune theme 랜덤 1개 선택(health, love, luck, success)
      final keys = fortuneThemeMap.keys.toList();
      fortuneTheme = keys[random.nextInt(keys.length)];
    } else {
      // user가 select한 fortune theme 사용
      fortuneTheme = sft;
    }

    // fortune theme json 파일 불러오기
    final String response = await rootBundle.loadString(
      'assets/datas/fortune/$fortuneTheme.json',
    );
    final List<dynamic> data = json.decode(response);

    // 랜덤 뽑기
    final randomFortuneMap = data[random.nextInt(data.length)];
    final fortune = randomFortuneMap['text'];
    final fortuneDescription = randomFortuneMap['description'];

    // 오늘 날짜 키
    final today = DateTime.now();
    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final prefs = await SharedPreferences.getInstance();
    // 저장
    await prefs.setString("saved_date", todayKey);
    await prefs.setString("saved_fortune", fortune);
    await prefs.setString("saved_fortune_description", fortuneDescription);
    await prefs.setString("saved_theme", fortuneThemeMap[fortuneTheme]!);

    Future.delayed(const Duration(seconds: 5), () {
      context.go(
        '/fortuneResult?ftt=${fortuneThemeMap[fortuneTheme]!}&ft=$fortune&ftd=$fortuneDescription',
      );
    });
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
        title: const SizedBox.shrink(),
      ),
      body: SpaceBackground(
        speed: 7.0,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQueryDogu.width(context) * 0.23,
                  child: Image.asset(
                    'assets/images/character/loading_dog.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: MediaQueryDogu.width(context) * 0.37,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          loadingMessage,
                          speed: const Duration(milliseconds: 60),
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(
                            color: Color(0xFFC0C0C0),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      totalRepeatCount: 1,
                      repeatForever: false,
                      isRepeatingAnimation: false,
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
