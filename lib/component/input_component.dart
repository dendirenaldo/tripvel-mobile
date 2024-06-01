import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputComponent extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? errorText;
  final bool? obscureText;
  // ignore: prefer_typing_uninitialized_variables
  final togglePasswordVisibility;
  final bool? readOnly;
  final bool? disabled;
  // ignore: prefer_typing_uninitialized_variables
  final onTap;
  final List<TextInputFormatter>? inputFormatters;
  final double? width;
  final int? maxLines;
  final FocusNode? focus;
  final IconData? prefixIcon;
  final void Function()? listen;
  final void Function(String)? onSubmit;

  const InputComponent({
    super.key,
    this.label,
    required this.controller,
    this.keyboardType,
    this.hintText,
    this.errorText,
    this.obscureText,
    this.togglePasswordVisibility,
    this.readOnly,
    this.disabled,
    this.onTap,
    this.inputFormatters,
    this.width,
    this.maxLines,
    this.focus,
    this.prefixIcon,
    this.listen,
    this.onSubmit,
  });

  @override
  State<InputComponent> createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(
              widget.label ?? '',
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 13),
              textScaleFactor: 1.0,
            ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: IgnorePointer(
              ignoring: widget.disabled ?? false,
              child: TextField(
                controller: widget.controller,
                obscureText: widget.obscureText ?? false,
                keyboardType: widget.keyboardType ?? TextInputType.text,
                readOnly: widget.readOnly ?? false,
                onTap: widget.onTap,
                inputFormatters: widget.inputFormatters,
                maxLines: widget.maxLines ?? 1,
                focusNode: widget.focus,
                onSubmitted: widget.onSubmit ?? (val) {},
                onChanged: (String? value) {
                  if (widget.listen != null) widget.listen!();
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                  suffixIcon: widget.togglePasswordVisibility != null && widget.obscureText != null
                      ? IconButton(
                          onPressed: widget.togglePasswordVisibility,
                          icon: Icon(
                            widget.obscureText != null && widget.obscureText == true ? Icons.visibility : Icons.visibility_off,
                          ),
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF4C5C7B),
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: (widget.disabled != null && widget.disabled == true) ? const Color(0xFFCCCCCC) : const Color(0xFFF4F7FF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
