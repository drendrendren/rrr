import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/dogu/palette.dart';

class DailyChecklistResultScreen extends StatefulWidget {
  const DailyChecklistResultScreen({super.key});

  @override
  State<DailyChecklistResultScreen> createState() =>
      _DailyChecklistResultScreenState();
}

// UUU 증상 별 조치 사항 글도 추후 추가하기
class _DailyChecklistResultScreenState
    extends State<DailyChecklistResultScreen> {
  late int checklistScore = 0;
  late String resultTitle = '';
  late String resultMessage = '';
  late Set<int> badHealthIndexSet = {};
  late List<String> checklistTitleList = [];
  late List<String> messageByKeywordList = [];
  late List<int> goodHealthIndexList = [];

  bool isDataReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isDataReady) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
      checklistScore = extra['cs'];
      resultTitle = extra['rt'];
      resultMessage = extra['rm'];
      badHealthIndexSet = Set<int>.from(extra['bhis']);
      checklistTitleList = List<String>.from(extra['ctl']);
      messageByKeywordList = List<String>.from(extra['mbkl']);
      goodHealthIndexList = List<int>.from(extra['ghil']);
      Future.delayed(const Duration(milliseconds: 4000), () {
        if (mounted) {
          setState(() {
            isDataReady = true;
          });
        }
      });
    }
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
              width: MediaQueryDogu.width(context) * 0.8,
              height: double.infinity,
              child:
                  isDataReady
                      ? Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      color: Colors.transparent,
                                      elevation: 5.0,
                                      shadowColor: Palette.shadowPrimary,
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
                                            horizontal: 15,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '$checklistScore점',
                                                  style: const TextStyle(
                                                    color: Color(0xFFFF6B6B),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 23,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: ' /100점',
                                                  style: TextStyle(
                                                    color:
                                                        Palette.textSecondary,
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
                                  ),
                                  const SizedBox(height: 2),
                                  Card(
                                    color: Colors.transparent,
                                    elevation: 5.0,
                                    shadowColor: Palette.shadowPrimary,
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
                                        child: ListTile(
                                          title: Text(
                                            resultTitle,
                                            style: const TextStyle(
                                              color: Palette.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Text(
                                            resultMessage,
                                            style: const TextStyle(
                                              color: Palette.textSecondary,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Card(
                                    color: Colors.transparent,
                                    elevation: 5.0,
                                    shadowColor: Palette.shadowPrimary,
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
                                            Color(0xFFFFD6D6),
                                            Color(0xFFE57373),
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 15,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '🚨 보완 포인트',
                                              style: TextStyle(
                                                color: Palette.textSecondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  badHealthIndexSet.length,
                                              itemBuilder: (context, index) {
                                                List<int> badHealthIndexList =
                                                    badHealthIndexSet.toList();
                                                final badHealthIndex =
                                                    badHealthIndexList[index];
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Chip(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFECA9A6,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 7,
                                                            ),
                                                        side: const BorderSide(
                                                          color:
                                                              Colors
                                                                  .transparent,
                                                          width: 0,
                                                        ),
                                                        label: Text(
                                                          checklistTitleList[badHealthIndex],
                                                          style: const TextStyle(
                                                            color:
                                                                Palette
                                                                    .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        messageByKeywordList[badHealthIndex],
                                                        style: const TextStyle(
                                                          color:
                                                              Palette
                                                                  .textSecondary,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Card(
                                    color: Colors.transparent,
                                    elevation: 5.0,
                                    shadowColor: Palette.shadowPrimary,
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
                                            Color(0xFFB2F2BB),
                                            Color(0xFF6CC57C),
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 15,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '✅ 좋았던 점',
                                              style: TextStyle(
                                                color: Palette.textSecondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  goodHealthIndexList.length,
                                              itemBuilder: (context, index) {
                                                final goodHealthIndex =
                                                    goodHealthIndexList[index];
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Chip(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFECA9A6,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 7,
                                                            ),
                                                        side: const BorderSide(
                                                          color:
                                                              Colors
                                                                  .transparent,
                                                          width: 0,
                                                        ),
                                                        label: Text(
                                                          checklistTitleList[goodHealthIndex],
                                                          style: const TextStyle(
                                                            color:
                                                                Palette
                                                                    .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        messageByKeywordList[goodHealthIndex],
                                                        style: const TextStyle(
                                                          color:
                                                              Palette
                                                                  .textSecondary,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: MediaQueryDogu.width(context) * 0.7,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.go('/profile');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Palette.primary,
                                        elevation: 8.0,
                                        shadowColor: Palette.shadowPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '홈으로 돌아가기',
                                        style: TextStyle(
                                          color: Palette.textTertiary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SpinKitFadingCircle(
                              color: Color(0xFF212121),
                              size: 40,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '결과 분석중이다멍!',
                              style: TextStyle(
                                color: Palette.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
