import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/widgets/screen/fortune_screen/chat_bubble_widget.dart';
import 'package:rrr/widgets/screen/fortune_screen/space_background_widget.dart';

class FortuneResultScreen extends StatefulWidget {
  final String fortuneTheme;
  final String fortune;
  final String fortuneDescription;

  const FortuneResultScreen({
    super.key,
    required this.fortuneTheme,
    required this.fortune,
    required this.fortuneDescription,
  });

  @override
  State<FortuneResultScreen> createState() => _FortuneResultScreenState();
}

class _FortuneResultScreenState extends State<FortuneResultScreen> {
  double _opacity = 0.5; // image하고 result card 전체 opacity animation 주기 위해
  String todayMd = '';
  String todayFortuneTheme = '';
  String todayFortune = '';
  String todayFortuneDescription = '';

  final Map<String, String> themeByEmojiMap = const {
    '전체': '🐕',
    '연애': '💘',
    '행운': '🍀',
    '성공': '📈',
    '건강': '⚡',
  };

  String addEmoji(String text) {
    final emoji = themeByEmojiMap[text];
    return emoji != null ? '$emoji $text' : text;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _opacity = 1.0);
    });
    final today = DateTime.now();
    setState(() {
      todayMd = "${today.month}월 ${today.day}일";
      todayFortuneTheme = addEmoji(widget.fortuneTheme);
      todayFortune = widget.fortune;
      todayFortuneDescription = widget.fortuneDescription;
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
        speed: 2.0,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .end, // result_dog image vertical 상으로 end에 위치하도록 하기 위해서
                  children: [
                    SizedBox(
                      width: MediaQueryDogu.width(context) * 0.17,
                      child: Image.asset(
                        'assets/images/character/result_dog.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width:
                          (MediaQuery.of(context).size.width >= 450)
                              ? 320
                              : MediaQueryDogu.width(context) * 0.6,
                      child: ChatBubble(
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 100),
                            opacity: _opacity,
                            curve: Curves.easeInOut,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$todayMd 오늘의 운세는 ',
                                        style: const TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '"$todayFortuneTheme" ',
                                        style: const TextStyle(
                                          color: Color(0xFFE3E3E3),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF448AFF),
                                              blurRadius: 3,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '운세다멍!\n',
                                        style: TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '오늘은 ',
                                        style: TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '"$todayFortune!"\n',
                                        style: const TextStyle(
                                          color: Color(0xFFE3E3E3),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF448AFF),
                                              blurRadius: 5,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: '자세히 말해주자면..\n',
                                        style: TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$todayFortuneDescription!\n',
                                        style: const TextStyle(
                                          color: Color(0xFFE0E0E0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF448AFF),
                                              blurRadius: 2,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  '오늘도 좋은 하루 보내라멍!',
                                  style: TextStyle(
                                    color: Color(0xFFE0E0E0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/profile');
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
                      '홈으로 돌아가기',
                      style: TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
