import 'dart:math';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../utils/utils.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final bool allowNegative;
  final String locale;
  final String symbol;

  final NumberFormat _formatter;

  CurrencyInputFormatter({
    this.decimalPlaces = 2,
    this.allowNegative = true,
    required this.locale,
    required this.symbol,
  }) : _formatter = NumberFormat.currency(
          decimalDigits: decimalPlaces,
          locale: locale,
          symbol: symbol,
        );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return textManipulation(
      oldValue,
      newValue,
      textInputFormatter: allowNegative
          ? FilteringTextInputFormatter.allow(RegExp('[0-9-]+'))
          : FilteringTextInputFormatter.digitsOnly,
      formatPattern: (String filteredString) {
        if (allowNegative) {
          // filter negative sign in the middle
          // this will also remove redundant negative signs
          if ('-'.allMatches(filteredString).isNotEmpty) {
            filteredString = (filteredString.startsWith('-') ? '-' : '') +
                filteredString.replaceAll('-', '');
          }
        }

        if (filteredString.isEmpty) return '';
        num number;
        number = int.tryParse(filteredString) ?? 0;
        if (decimalPlaces > 0) {
          number /= pow(10, decimalPlaces);
        }
        final result = _formatter.format(number);

        // Fix the -0+ and similar issues
        if (allowNegative) {
          if (filteredString == '-' ||
              RegExp(r'-0?0+$').hasMatch(filteredString)) {
            return '-';
          }
        }

        return result;
      },
    );
  }
}
