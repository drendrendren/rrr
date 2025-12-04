import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:just_audio/just_audio.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/dogu/palette.dart';
import 'package:rrr/widgets/screen/home_screen/action_button_widget.dart';
import 'package:rrr/widgets/screen/home_screen/command_button_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ============================= text -> dog lang =============================
  late AudioPlayer player;
  final TextEditingController _languageInputController =
      TextEditingController();

  final int textFieldHintTextNum =
      10; // json translations 파일에 있는 hintTexts 개수(hintTexts 추가 시 이 변수 ++ 해줘야함)
  late String textFieldHintText =
      '보리야 사랑해'; // 사용자가 입력하는 textField 뒤에 보여지는 hintText(random으로 문구 하나 선정함)
  late Map<String, String> commandMap = {
    'sit': 'sit'.tr(),
    'stay': 'stay'.tr(),
    'come': 'come'.tr(),
    'paw': 'paw'.tr(),
    'down': 'down'.tr(),
    'turn': 'turn'.tr(),
  }; // command에 따른 sound file 매치되어 있는 map
  final InAppReview _inAppReview = InAppReview.instance; // 인앱리뷰

  @override
  void initState() {
    super.initState();
    textFieldHintText =
        'home_screen_hint_texts.${Random().nextInt(textFieldHintTextNum + 1)}'
            .tr();
    player = AudioPlayer();
    dogLangRecordingPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // 깜빡이는 속도
      lowerBound: 0.97, // 깜빡일 때 최소 크기
      upperBound: 1.03, // 깜빡일 때 최대 크기
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) dogLangRecordingPulse.reverse();
      if (s == AnimationStatus.dismissed) dogLangRecordingPulse.forward();
    });
    loadTranslatorStatus();
    _checkMonthlyReview();
  }

  // input 문장에 key 없을 때에도 매번 같은 소리 나오도록 하기 위해 사용함
  int hashString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = (hash * 31 + text.codeUnitAt(i)) % 1000000007;
    }
    return hash;
  }

  String getSoundName(String text) {
    final hash = hashString(text);
    final index = (hash % 14) + 1; // 1부터 14까지
    return 'r$index'; // 예: r3, r12
  }

  // text -> dog lang
  void text2DogLang({required String text, required Map<String, String> cm}) {
    String trimmedText = text.trim(); // 앞뒤 공백 제거

    Map<String, int> keyCounts = {};

    for (final key in commandMap.values) {
      // key(command)가 몇 번 등장했는지 count
      final regExp = RegExp(RegExp.escape(key));
      final matches = regExp.allMatches(trimmedText);
      final count = matches.length;

      if (count > 0) {
        keyCounts[key] = count;
      }
    }

    List<String> commandList = [];
    late String soundCommand = '';
    if (keyCounts.isNotEmpty) {
      final String mostFrequentKey =
          keyCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

      commandList.add(cm[mostFrequentKey] ?? 'paw');
      soundCommand =
          cm.entries.firstWhere((entry) => entry.value == mostFrequentKey).key;
    } else {
      // input된 문장에 key 1개도 X
      // random sound 들려주기
      String randomNumber = getSoundName(trimmedText);

      commandList.add(randomNumber);
      soundCommand = randomNumber;
    }

    // UUU 문장 길어지면 repeatNum 늘리기
    _playDogLang(repeatNum: 1, command: soundCommand);
  }

  Future<void> _playDogLang({
    required int repeatNum,
    required String command,
  }) async {
    final String cm = command;

    for (int i = 0; i < repeatNum; i++) {
      player = AudioPlayer();
      await player.setAsset(
        'assets/sounds/dog_lang/$cm.mp3',
      ); // NNN 소리 안날 시 경로에 assets/ 확인하기
      await player.play();
      await player.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // ============================= dog lang -> text =============================
  late bool isText2DogLang =
      true; // 텍스트 -> 강아지 소리 인지 강아지 소리 -> 텍스트인지 상태 알려주는 변수
  bool isDogLangRecording = false; // dog lang 녹음 중인지 상태 알려주는 변수
  bool isDogLangRecordingFinish = false; // dog lang 녹음 끝났는지 상태 알려주는 변수
  late AnimationController
  dogLangRecordingPulse; // mic icon button 깜빡거리는 animation
  final int dogLang2TextNum =
      29; // json translations 파일에 있는 dog lang -> text 개수(추가 시 이 변수 ++ 해줘야함)
  late String dogLang2TextResultText = '';

  // isText2DogLang 상태 share preferences 에서 불러오는 함수
  Future<void> loadTranslatorStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool it2dl = prefs.getBool('isText2DogLang') ?? true;

    setState(() {
      isText2DogLang = it2dl;
    });
  }

  // isText2DogLang 상태 share preferences 에 저장하는 함수
  Future<void> saveTranslatorStatus({required bool it2dl}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isText2DogLang', it2dl);
  }

  // mic icon button click 해서 dog lang 녹음하는 함수
  void dogLangRecordingClick() {
    // 깜빡거림 시작
    dogLangRecordingPulse.forward();
    setState(() {
      isDogLangRecording = true;
    });
  }

  // dog lang -> text 로 변환하는 함수
  void dogLang2Text() {
    // 깜빡거림 종료
    dogLangRecordingPulse.reset();
    setState(() {
      // translations에서 random한 dog lang -> text 가져옴
      dogLang2TextResultText =
          'home_screen_dog_lang_2_texts.${Random().nextInt(dogLang2TextNum + 1)}'
              .tr();

      isDogLangRecording = false;
      isDogLangRecordingFinish = true;
    });
  }

  // 앱 리뷰 요청하는 함수(30일에 한번씩 호출)
  // shared preferences로 관리
  // UUU android도 추후 추가하기
  Future<void> _checkMonthlyReview() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 마지막 요청 날짜 가져오기
    final lastRequestString = prefs.getString("lastReviewDate");

    if (lastRequestString != null) {
      final lastDate = DateTime.parse(lastRequestString);
      final diff = now.difference(lastDate).inDays;

      // 30일 미만 —> exit
      if (diff < 30) return;
    }

    // 30일 지났으면 리뷰 요청
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
      // 마지막 요청 날짜 업데이트
      await prefs.setString("lastReviewDate", now.toIso8601String());
    } catch (e) {
      debugPrint("리뷰 요청 실패: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    _languageInputController.dispose();
    dogLangRecordingPulse.dispose();
    super.dispose();
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
        centerTitle: false,
        title: SizedBox(
          height: 25,
          child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
        ),
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
            height: MediaQueryDogu.height(context) * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // isText2DogLang 상태가 true일 때 commandMap list 보여줌
                isText2DogLang
                    ? CommandButtonListWidget(
                      cm: commandMap,
                      lic: _languageInputController,
                    )
                    : const SizedBox.shrink(),
                // 번역 arrow 중간에 위치하게 하기 위해 Stack widget 사용
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // isText2DogLang가 true일 때
                        // text -> dog lang
                        SizedBox(
                          width: MediaQueryDogu.width(context) * 0.33,
                          child: Center(
                            child: Text(
                              isText2DogLang
                                  ? '한국어'
                                  : 'home_screen_target_language'.tr(),
                              style: const TextStyle(
                                color: Palette.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        // isText2DogLang가 false일 때
                        // dog lang -> text
                        SizedBox(
                          width: MediaQueryDogu.width(context) * 0.33,
                          child: Center(
                            child: Text(
                              isText2DogLang
                                  ? 'home_screen_target_language'.tr()
                                  : '한국어',
                              style: const TextStyle(
                                color: Palette.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Palette.borderPrimary,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isText2DogLang = !isText2DogLang;
                              saveTranslatorStatus(it2dl: isText2DogLang);
                            });
                          },
                          iconSize: 17,
                          icon: SvgPicture.asset(
                            'assets/icons/svgs/home_screen/sync_alt.svg',
                            width: 17,
                            color: Palette.iconPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // isText2DogLang 상태에 따라 textfield를 보여줄지, 녹음 iconbutton을 보여줄지 결정함
                // true: text -> dog lang 이므로 textfield와 변환 iconbutton 만 보여줌
                // false: dog lang -> text 이므로 micbutton과 설명 text만 보여줌
                SizedBox(
                  width: MediaQueryDogu.width(context) * 0.8,
                  //height: MediaQueryDogu.height(context) * 0.2,
                  child:
                      isText2DogLang
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _languageInputController,
                                keyboardType: TextInputType.text,
                                maxLength: 30,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: textFieldHintText,
                                  border: const OutlineInputBorder(),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.borderPrimary,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.borderSecondary,
                                      width: 2,
                                    ),
                                  ),
                                  counterStyle: const TextStyle(
                                    color: Palette.textSecondary,
                                  ),
                                ),
                                cursorColor: Palette.cursorPrimary,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Palette.textPrimary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: ActionButtonWidget(
                                  onPressed: () {
                                    final String inputText =
                                        _languageInputController.text;

                                    if (inputText.isNotEmpty) {
                                      text2DogLang(
                                        text: inputText,
                                        cm: commandMap,
                                      );
                                    }
                                  },
                                  buttonText:
                                      'home_screen_text_2_dog_lang_retry_button_text'
                                          .tr(),
                                  buttonIcon: SvgPicture.asset(
                                    'assets/icons/svgs/home_screen/pets.svg',
                                    width: 17,
                                    color: Palette.secondary,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : (!isDogLangRecordingFinish)
                          // isDogLangRecordingFinish의 상태 즉, recording 끝났는지에 따라 위젯들 보여줌
                          // true: mic recording icon button
                          // false: dogLang2TextResultText(번역 결과)
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: dogLangRecordingPulse,
                                builder:
                                    (_, child) => Transform.scale(
                                      scale:
                                          isDogLangRecording
                                              ? dogLangRecordingPulse.value
                                              : 1.0,
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              isDogLangRecording
                                                  ? Palette.primary
                                                  : Colors.transparent,
                                          boxShadow:
                                              isDogLangRecording
                                                  ? [
                                                    const BoxShadow(
                                                      color:
                                                          Palette
                                                              .shadowSecondary,
                                                      blurRadius: 20,
                                                      spreadRadius: 5,
                                                    ),
                                                  ]
                                                  : [],
                                        ),
                                        child: IconButton(
                                          onPressed:
                                              isDogLangRecording
                                                  ? dogLang2Text
                                                  : dogLangRecordingClick,
                                          icon: SvgPicture.asset(
                                            'assets/icons/svgs/home_screen/mic.svg',
                                            width: 30,
                                            color:
                                                isDogLangRecording
                                                    ? Palette.iconTertiary
                                                    : Palette.iconPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                              Text(
                                isDogLangRecording
                                    ? 'home_screen_dog_lang_recording_text'.tr()
                                    : 'home_screen_dog_lang_recording_hint_text'
                                        .tr(),
                                style: const TextStyle(
                                  color: Palette.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                          : Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DefaultTextStyle(
                                  style: const TextStyle(
                                    color: Palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        '"$dogLang2TextResultText"',
                                        speed: const Duration(
                                          milliseconds: 100,
                                        ),
                                        cursor: '',
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                    pause: const Duration(milliseconds: 500),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ActionButtonWidget(
                                  onPressed: () {
                                    setState(() {
                                      isDogLangRecording = false;
                                      isDogLangRecordingFinish = false;
                                    });
                                  },
                                  buttonText:
                                      'home_screen_dog_lang_2_text_retry_button_text'
                                          .tr(),
                                  buttonIcon: SvgPicture.asset(
                                    'assets/icons/svgs/home_screen/refresh.svg',
                                    width: 17,
                                    color: Palette.iconTertiary,
                                  ),
                                ),
                              ],
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
