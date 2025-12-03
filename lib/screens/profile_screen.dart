import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:rrr/widgets/global/card_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rrr/dogu/media_query.dart';
import 'package:rrr/dogu/palette.dart';
import 'package:rrr/dogu/date_input_formater.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// UUU 사진 업로드 기능 추가하기
class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  final TextEditingController nameEditController = TextEditingController();
  final TextEditingController detailsEditController = TextEditingController();
  final TextEditingController ymdEditController = TextEditingController();
  final String nameEditTextFieldHintText =
      'profile_screen_name_edit_hint_text'.tr();
  final String detailsEditTextFieldHintText =
      'profile_screen_details_edit_hint_text'.tr();
  final String ymdEditTextFieldHintText =
      'profile_screen_ymd_edit_hint_text'.tr();
  late bool isNameEditValueCorrect = true; // nameEdit textfield 양식 확인 결과
  late bool isDetailsEditValueCorrect = true; // detailsEdit textfield 양식 확인 결과
  late bool isYmdEditValueCorrect = true; // ymdEdit textfield 양식 확인 결과

  Uint8List? userImage;
  @override
  void initState() {
    super.initState();
    loadProfileDatas();
  }

  late String profileName = '';
  late String profileDetails = '';
  late String targetDate = '';
  late String dDay = '';

  Future<void> loadProfileDatas() async {
    final prefs = await SharedPreferences.getInstance();
    final String profileNameData =
        prefs.getString('profileName') ?? 'example_dog_name'.tr();
    final String profileDetailsData =
        prefs.getString('profileDetails') ??
        'profile_screen_example_dog_details'.tr();
    final String targetDateData = prefs.getString('targetDate') ?? '2025-12-02';

    setState(() {
      profileName = profileNameData;
      profileDetails = profileDetailsData;
      targetDate = targetDateData;
      daysSince(targetDateData);
    });
  }

  Future<void> saveProfileDatas({
    required String pn,
    required String pd,
    required String td,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileName', pn);
    await prefs.setString('profileDetails', pd);
    await prefs.setString('targetDate', td);
  }

  // target date로부터 지난 날 계산
  void daysSince(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    String difference =
        '${today.difference(parsedDate).inDays} ${'profile_screen_d_day'.tr()}'; // 날짜 단위 추가됨

    setState(() {
      dDay = difference;
    });
  }

  // ymd 형식 판별 일치하는지
  bool isValidPastDate(String input) {
    // 1. YYYY-MM-DD 형식인지 확인
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(input)) return false;

    // 2. DateTime으로 파싱
    final parsedDate = DateTime.tryParse(input);
    if (parsedDate == null) return false;

    // 3. 입력값과 파싱값이 정확히 일치하는지 확인
    final parts = input.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    if (parsedDate.year != year ||
        parsedDate.month != month ||
        parsedDate.day != day) {
      return false; // 자동 보정된 날짜임
    }

    // 4. 오늘 날짜보다 미래인지 검사
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (parsedDate.isAfter(today)) {
      return false;
    }

    return true;
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 상단 profile(image, name, details)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Palette.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isEditing
                              ? SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: nameEditController,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: nameEditTextFieldHintText,
                                    border: const UnderlineInputBorder(),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            isNameEditValueCorrect
                                                ? Palette.borderPrimary
                                                : Palette.errorPrimary,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            isNameEditValueCorrect
                                                ? Palette.borderSecondary
                                                : Palette.errorPrimary,
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 2,
                                    ),
                                    counterStyle: const TextStyle(
                                      color: Palette.textSecondary,
                                    ),
                                    counterText: "",
                                  ),
                                  cursorColor: Palette.cursorPrimary,
                                  style: const TextStyle(
                                    color: Palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : Text(
                                profileName,
                                style: const TextStyle(
                                  color: Palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          isEditing
                              ? SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: detailsEditController,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: detailsEditTextFieldHintText,
                                    border: const UnderlineInputBorder(),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            isDetailsEditValueCorrect
                                                ? Palette.borderPrimary
                                                : Palette.errorPrimary,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            isDetailsEditValueCorrect
                                                ? Palette.borderSecondary
                                                : Palette.errorPrimary,
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 2,
                                    ),
                                    counterStyle: const TextStyle(
                                      color: Palette.textSecondary,
                                    ),
                                    counterText: "",
                                  ),
                                  cursorColor: Palette.cursorPrimary,
                                  style: const TextStyle(
                                    color: Palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                              : Text(
                                profileDetails,
                                style: const TextStyle(
                                  color: Palette.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  height: 0.9,
                                ),
                              ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // edit icon button click됨
                        setState(() {
                          if (!isEditing) {
                            nameEditController.text = profileName ?? '';
                            detailsEditController.text = profileDetails ?? '';
                            ymdEditController.text = targetDate ?? '';
                            isEditing = !isEditing;
                          } else {
                            final pn = nameEditController.text;
                            final pd = detailsEditController.text;
                            final td = ymdEditController.text;

                            if (pn.isNotEmpty &&
                                pd.isNotEmpty &&
                                td.isNotEmpty &&
                                isValidPastDate(td)) {
                              setState(() {
                                isNameEditValueCorrect = true;
                                isDetailsEditValueCorrect = true;
                                isYmdEditValueCorrect = true;
                              });

                              saveProfileDatas(pn: pn, pd: pd, td: td);
                              setState(() {
                                profileName = pn;
                                profileDetails = pd;
                                targetDate = td;
                                daysSince(td);
                                isEditing = !isEditing;
                              });
                            } else {
                              setState(() {
                                isNameEditValueCorrect =
                                    (pn.isEmpty) ? false : true;
                                isDetailsEditValueCorrect =
                                    (pd.isEmpty) ? false : true;
                                isYmdEditValueCorrect =
                                    (td.isEmpty || !isValidPastDate(td))
                                        ? false
                                        : true;
                              });
                            }
                          }
                        });
                      },
                      icon: Icon(
                        !isEditing ? Icons.edit : Icons.check,
                        color: Palette.iconPrimary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                // D-day card
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: FadeSlideAnimationWidget(
                    offset: const Offset(0, 5),
                    duration: const Duration(milliseconds: 500),
                    child: Card(
                      color: Palette.secondary,
                      elevation: 8.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 15,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  isEditing
                                      ? SizedBox(
                                        width: 110,
                                        child: TextField(
                                          controller: ymdEditController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(8),
                                            DateInputFormatter(),
                                          ],
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: ymdEditTextFieldHintText,
                                            border:
                                                const UnderlineInputBorder(),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    isYmdEditValueCorrect
                                                        ? Palette.borderPrimary
                                                        : Palette.errorPrimary,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    isYmdEditValueCorrect
                                                        ? Palette
                                                            .borderSecondary
                                                        : Palette.errorPrimary,
                                                width: 1,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 6,
                                                  horizontal: 2,
                                                ),
                                            counterStyle: const TextStyle(
                                              color: Palette.textSecondary,
                                            ),
                                            counterText: "",
                                          ),
                                          cursorColor: Palette.cursorPrimary,
                                          style: const TextStyle(
                                            color: Palette.textSecondary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                      : Text(
                                        targetDate,
                                        style: const TextStyle(
                                          color: Palette.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                dDay,
                                style: const TextStyle(
                                  color: Palette.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                !isEditing
                    ? GestureDetector(
                      onTap: () {
                        context.push('/fortune');
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: FadeSlideAnimationWidget(
                          offset: const Offset(0, 5),
                          duration: const Duration(milliseconds: 1000),
                          child: Card(
                            color: Colors.transparent,
                            elevation: 8.0,
                            shadowColor: Palette.shadowPrimary,
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.purple.shade800,
                                    Colors.deepPurple.shade900,
                                    Colors.indigo.shade900,
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 25,
                                      child: Image.asset(
                                        'assets/images/character/luck_dog.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const Expanded(
                                      child: ListTile(
                                        title: Text(
                                          '멍운세',
                                          style: TextStyle(
                                            color: Color(0xFFE0E0E0),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '오늘의 운세를 확인해라멍!',
                                          style: TextStyle(
                                            color: Color(0xFFC0C0C0),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
                !isEditing
                    ? GestureDetector(
                      onTap: () {
                        context.push('/dailyChecklist');
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: FadeSlideAnimationWidget(
                          offset: const Offset(0, 5),
                          duration: const Duration(milliseconds: 1500),
                          child: Card(
                            color: Colors.transparent,
                            elevation: 8.0,
                            shadowColor: Palette.shadowPrimary,
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD67C78),
                                    Color(0xFFB34F4B),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 25,
                                      child: Image.asset(
                                        'assets/images/character/health_dog.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const Expanded(
                                      child: ListTile(
                                        title: Text(
                                          '건강 체크리스트',
                                          style: TextStyle(
                                            color: Palette.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '매일 30초만 투자해라멍!',
                                          style: TextStyle(
                                            color: Palette.textSecondary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
