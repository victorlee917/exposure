import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/fonts.dart';
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryTextField extends StatefulWidget {
  const PrimaryTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.maxLines = 1,
    this.border,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextAlign textAlign;
  final bool autocorrect;
  final bool enableSuggestions;
  final int maxLines;
  final InputBorder? border;

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller?.removeListener(_onTextChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  void _onTextChanged() {
    setState(() {
      // This is needed to trigger a rebuild when text changes
      // which affects the alignment.
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isHintCentered =
        !_hasFocus && (widget.controller?.text.isEmpty ?? true);

    return TextField(
      maxLines: widget.maxLines,
      controller: widget.controller,
      focusNode: _focusNode,
      textAlign: isHintCentered ? TextAlign.center : widget.textAlign,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: isDarkMode ? Colors.white : Colors.black,
      cursorHeight: Sizes.sizeTextFieldFont,
      style: TextStyle(
        fontSize: Sizes.sizeTextFieldFont,
        fontWeight: Fonts.weightBold,
        // When text is centered, we might need to adjust the alignment of the style
        // But textAlign property of TextField handles this well.
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: Sizes.sizeTextFieldFont,
          color: isDarkMode ? Fonts.colorHintDark : Fonts.colorHintLight,
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white38 : Colors.black45,
          fontSize: Sizes.sizeTextFieldFont,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: Sizes.size16,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        errorText: widget.errorText,
        errorStyle: TextStyle(
          fontSize: Sizes.size12,
          color: isDarkMode ? Colors.redAccent : Colors.red,
        ),
        border: widget.border,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Rvalues.button),
          borderSide: BorderSide(
            color: isDarkMode ? Borders.lineColorDark : Borders.lineColorLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Rvalues.button),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Rvalues.button),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.redAccent : Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Rvalues.button),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.redAccent : Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Paddings.textFieldHorizontal,
          vertical: Paddings.textFieldVertical,
        ),
      ),
    );
  }
}
