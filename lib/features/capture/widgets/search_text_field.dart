import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final void Function(String) onSubmitted;
  final void Function() onClear;
  final void Function(String) onChanged;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSubmitted,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: TextField(
        maxLines: 1,
        autocorrect: false,
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDarkMode ? Fonts.colorHintDark : Fonts.colorHintLight,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Paddings.textFieldHorizontal,
            vertical: Paddings.textFieldVertical,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Rvalues.button),
            borderSide: BorderSide(
              color: isDarkMode
                  ? Borders.lineColorDark
                  : Borders.lineColorLight,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Rvalues.button),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Rvalues.button),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear',
                  icon: Icon(
                    Icons.clear,
                    color: isDarkMode
                        ? Borders.lineColorDark
                        : Borders.lineColorLight,
                  ),
                  onPressed: onClear,
                )
              : IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    focusNode.unfocus();
                    onSubmitted(controller.text);
                  },
                ),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: Sizes.sizeTextFieldFont,
        ),
        cursorColor: isDarkMode ? Colors.white : Colors.black,
        cursorHeight: Sizes.sizeTextFieldFont,
        onChanged: onChanged,
      ),
    );
  }
}
