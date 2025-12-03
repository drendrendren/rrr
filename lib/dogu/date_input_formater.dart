import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    raw = raw.substring(0, raw.length.clamp(0, 8)); // 최대 8자리

    final buffer = StringBuffer();
    int selectionIndex = raw.length;

    for (int i = 0; i < raw.length; i++) {
      buffer.write(raw[i]);
      if ((i == 3 || i == 5) && i != raw.length - 1) {
        buffer.write('-');
        selectionIndex++;
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
