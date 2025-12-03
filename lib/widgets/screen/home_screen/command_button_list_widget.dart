import 'package:flutter/material.dart';
import 'package:rrr/dogu/palette.dart';

// 번역 입력창 위에 있는 예시 문구들 보여주는 위젯
// 예) 손, 이리와 등..
class CommandButtonListWidget extends StatefulWidget {
  final Map<String, String> cm;
  final TextEditingController lic;

  const CommandButtonListWidget({
    super.key,
    required this.cm,
    required this.lic,
  });

  @override
  State<CommandButtonListWidget> createState() =>
      _CommandButtonListWidgetState();
}

class _CommandButtonListWidgetState extends State<CommandButtonListWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
              widget.cm.entries
                  .map(
                    (command) => Container(
                      height: 23,
                      margin: const EdgeInsets.only(right: 5),
                      child: TextButton(
                        onPressed: () {
                          widget.lic.clear();
                          widget.lic.text = command.value;
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Palette.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          elevation: 2,
                          shadowColor: Palette.shadowPrimary,
                        ),
                        child: Text(
                          command.value, // 번역된 command
                          style: const TextStyle(
                            color: Palette.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
