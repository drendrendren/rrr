import 'package:flutter/material.dart';
import 'package:rrr/dogu/palette.dart';
import 'package:rrr/dogu/media_query.dart';

class ActionButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Widget? buttonIcon;

  const ActionButtonWidget({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQueryDogu.width(context) * 0.5,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.primary,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (buttonIcon != null) buttonIcon!,
            if (buttonIcon != null) const SizedBox(width: 7),
            Text(
              buttonText,
              style: const TextStyle(
                color: Palette.textTertiary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
