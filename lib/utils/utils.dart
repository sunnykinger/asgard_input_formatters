import 'dart:math';

import 'package:flutter/services.dart';

TextEditingValue textManipulation(
  TextEditingValue oldValue,
  TextEditingValue newValue, {
  TextInputFormatter? textInputFormatter,
  String Function(String filteredString)? formatPattern,
}) {
  final originalUserInput = newValue.text;

  /// remove all invalid characters
  final modValue = textInputFormatter != null
      ? textInputFormatter.formatEditUpdate(oldValue, newValue)
      : newValue;

  /// current selection
  int selectionIndex = modValue.selection.end;

  /// format original string, this step would add some separator characters
  final newText =
      formatPattern != null ? formatPattern(modValue.text) : modValue.text;

  if (newText == modValue.text) {
    return modValue;
  }

  /// count number of inserted character in new string
  int insertCount = 0;

  /// count number of original input character in new string
  int inputCount = 0;

  bool _isUserInput(String s) {
    if (textInputFormatter == null) return originalUserInput.contains(s);
    return modValue.text.contains(s);
  }

  for (int i = 0; i < newText.length && inputCount < selectionIndex; i++) {
    final character = newText[i];
    if (_isUserInput(character)) {
      inputCount++;
    } else {
      insertCount++;
    }
  }

  /// adjust selection according to number of inserted characters staying before selection
  selectionIndex += insertCount;
  selectionIndex = min(selectionIndex, newText.length);

  /// if selection is right after an inserted character, it should be moved
  /// backward, this adjustment prevents an issue that user cannot delete
  /// characters when cursor stands right after inserted characters
  if (selectionIndex - 1 >= 0 &&
      selectionIndex - 1 < newText.length &&
      !_isUserInput(newText[selectionIndex - 1])) {
    selectionIndex--;
  }
  // print('inputCount: $inputCount');
  // print('insertCount: $insertCount');

  return modValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty);
}

TextEditingValue textManipulationV2(
  TextEditingValue oldValue,
  TextEditingValue newValue, {
  TextInputFormatter? textInputFormatter,
  String Function(String filteredString)? formatPattern,
}) {
  /// remove all invalid characters
  var modValue = textInputFormatter != null
      ? textInputFormatter.formatEditUpdate(oldValue, newValue)
      : newValue;

  /// format original string, this step would add some separator characters
  final newText =
      formatPattern != null ? formatPattern(modValue.text) : modValue.text;

  if (newText == modValue.text) {
    return modValue;
  }

  return modValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty);
}
