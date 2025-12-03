import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/dogu/palette.dart';
import 'package:rrr/widgets/global/card_animation_widget.dart';

class DailyChecklistScreen extends StatefulWidget {
  const DailyChecklistScreen({super.key});

  @override
  State<DailyChecklistScreen> createState() => _DailyChecklistScreenState();
}

class _DailyChecklistScreenState extends State<DailyChecklistScreen> {
  static const int maxScore = 20; // 다 좋음 체크 시 나올 수 있는 최대 점수
  int cardAnimationDuration = 0; // listview 안에 있는 card animation간 간격 주기 위함
  bool isLoading =
      true; // data들 다 로딩되었는지 관리함(true: 콘텐츠 보여줌, false: loading spinkit 보여줌)
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> resultMessageMap = {};
  Map<String, dynamic> resultMessageByKeywordMap = {};
  List<GlobalKey> cardKeyList = [];
  List<dynamic> checklist = [];
  List<String> checklistTitleList = [];
  Map<int, String> selectedOptions = {}; // 사용자가 선택한 optinos 저장
  Set<int> badHealthIndexSet = {}; // score 0으로 선택한 항목의 index 저장
  List<int> goodHealthIndexList = []; // badHealthIndex 빼고 나머지 index 저장
  int checklistScore = 0;
  String resultTitle = '';
  String resultMessage = '';
  List<String> messageByKeywordList = [];

  @override
  void initState() {
    super.initState();
    loadChecklistData();
    cardKeyList = List.generate(10, (_) => GlobalKey());
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> loadChecklistData() async {
    final String questionJson = await rootBundle.loadString(
      'assets/datas/health/daily_checklist/daily_checklist_question.json',
    );
    final questionData = await json.decode(questionJson);

    final String messageJson = await rootBundle.loadString(
      'assets/datas/health/daily_checklist/daily_checklist_result_message.json',
    );
    final messageData = json.decode(messageJson);

    final String messageByKeywordJson = await rootBundle.loadString(
      'assets/datas/health/daily_checklist/daily_checklist_result_message_by_keyword.json',
    );
    final messageByKeywordData = json.decode(messageByKeywordJson);

    setState(() {
      checklist = questionData;
      for (var i = 0; i < checklist.length; i++) {
        checklistTitleList.add(checklist[i]['title']);
      }
      resultMessageMap = messageData;
      resultMessageByKeywordMap = messageByKeywordData;
    });
  }

  void checkAndScroll() {
    for (int i = 0; i < cardKeyList.length; i++) {
      if (!selectedOptions.containsKey(i)) {
        final key = cardKeyList[i];
        final keyContext = key.currentContext;

        if (keyContext == null) {
          continue;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            Scrollable.ensureVisible(
              keyContext,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              alignment: 0.2,
            );
          } catch (e) {}
        });

        break;
      }
    }
  }

  Future<void> getMessageFromScore({required int score}) async {
    String range;
    String title;
    if (score >= 90) {
      title = '완벽하다멍!';
      range = '90-100';
    } else if (score >= 70) {
      title = '거의 완벽하다멍!';
      range = '70-89';
    } else if (score >= 50) {
      title = '조금 더 신경써라멍!';
      range = '50-69';
    } else if (score >= 30) {
      title = '더 신경써라멍!';
      range = '30-49';
    } else {
      title = '빨리 챙겨라멍!';
      range = '0-29';
    }

    final List messages = resultMessageMap[range];

    setState(() {
      resultTitle = title;
      resultMessage = messages[Random().nextInt(messages.length)];
    });
  }

  // keyword 즉 card의 제목으로 메시지를 가져옴
  Future<void> keywordMessageFromScore({
    required String title,
    required int score,
  }) async {
    // title에서 이모지 제거
    final cleanTitle =
        title.replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z0-9\s]'), '').trim();

    final String type = score != 0 ? 'good' : 'bad';

    if (!resultMessageByKeywordMap.containsKey(cleanTitle)) {
      return;
    }

    final List messages = resultMessageByKeywordMap[cleanTitle][type];
    final String message = messages[Random().nextInt(messages.length)];
    messageByKeywordList.add(message);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const SizedBox.shrink(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD67C78), Color(0xFFB34F4B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: MediaQueryDogu.width(context) * 0.87,
              height: double.infinity,
              child:
                  !isLoading
                      ? Column(
                        children: [
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  controller: _scrollController,
                                  itemCount: checklist.length,
                                  itemBuilder: (context, index) {
                                    final item = checklist[index];
                                    final String checklistTitle =
                                        checklistTitleList[index];
                                    final String checklistDescription =
                                        item['description'];
                                    final List checklistOptionList =
                                        item['options'];
                                    cardAnimationDuration += 100;
                                    return FadeSlideAnimationWidget(
                                      offset: const Offset(0, 5),
                                      duration: Duration(
                                        milliseconds: cardAnimationDuration,
                                      ),
                                      child: Card(
                                        key: cardKeyList[index],
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 3,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFFFF7F6),
                                                Color(0xFFFFEAE7),
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 5,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    checklistTitle,
                                                    style: const TextStyle(
                                                      color:
                                                          Palette.textPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    checklistDescription,
                                                    style: const TextStyle(
                                                      color:
                                                          Palette.textSecondary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 5,
                                                  ),
                                                  child: Wrap(
                                                    spacing: 4,
                                                    children: List<
                                                      Widget
                                                    >.generate(
                                                      checklistOptionList
                                                          .length,
                                                      (optionIndex) {
                                                        final option =
                                                            checklistOptionList[optionIndex];
                                                        final isSelected =
                                                            selectedOptions[index] ==
                                                            option;
                                                        return ChoiceChip(
                                                          label: Text(option),
                                                          selected: isSelected,
                                                          onSelected: (_) {
                                                            setState(() {
                                                              selectedOptions[index] =
                                                                  option;
                                                            });
                                                          },
                                                          selectedColor:
                                                              const Color(
                                                                0xFFB05551,
                                                              ),
                                                          backgroundColor:
                                                              const Color(
                                                                0xFFECA9A6,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                3,
                                                              ),
                                                          side: const BorderSide(
                                                            color:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                          labelStyle: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? Palette
                                                                        .textTertiary
                                                                    : Palette
                                                                        .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          showCheckmark: false,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 30),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      checkAndScroll();

                                      num totalScore = 0;

                                      for (
                                        var i = 0;
                                        i < checklist.length;
                                        i++
                                      ) {
                                        String selectedOption =
                                            selectedOptions[i]!;

                                        List<String> options =
                                            List<String>.from(
                                              checklist[i]['options'],
                                            );
                                        List<int> scores = List<int>.from(
                                          checklist[i]['score'],
                                        );

                                        int index = options.indexOf(
                                          selectedOption,
                                        );

                                        if (index != -1) {
                                          totalScore += scores[index];
                                          if (scores[index] == 0) {
                                            badHealthIndexSet.add(i);
                                          }
                                        } else {
                                          checkAndScroll();
                                        }
                                        keywordMessageFromScore(
                                          title: checklist[i]['title'],
                                          score: scores[index],
                                        );
                                      }

                                      setState(() {
                                        checklistScore =
                                            ((totalScore / maxScore) * 100)
                                                .round();
                                        getMessageFromScore(
                                          score: checklistScore,
                                        );
                                        goodHealthIndexList =
                                            List.generate(
                                                  checklist.length,
                                                  (i) => i,
                                                )
                                                .where(
                                                  (i) =>
                                                      !badHealthIndexSet
                                                          .contains(i),
                                                )
                                                .toList();

                                        context.go(
                                          '/dailyChecklistResult',
                                          extra: {
                                            'cs': checklistScore,
                                            'rt': resultTitle,
                                            'rm': resultMessage,
                                            'bhis': badHealthIndexSet,
                                            'ctl': checklistTitleList,
                                            'mbkl': messageByKeywordList,
                                            'ghil': goodHealthIndexList,
                                          },
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Palette.primary,
                                      elevation: 8.0,
                                      shadowColor: Palette.shadowPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: const Text(
                                      '결과 확인하기',
                                      style: TextStyle(
                                        color: Palette.textTertiary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : const Center(
                        child: SpinKitFadingCircle(
                          color: Color(0xFF212121),
                          size: 20,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
