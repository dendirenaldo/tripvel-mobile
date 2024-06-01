import 'package:flutter/material.dart';

class ButtonComponent extends StatelessWidget {
  final String label;
  final double? margin;
  final void Function() onClick;
  final int? color;
  final double? borderRadius;
  final double? width;
  final bool? disabled;

  const ButtonComponent({
    super.key,
    required this.label,
    required this.onClick,
    this.margin,
    this.color,
    this.borderRadius,
    this.width,
    this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      margin: EdgeInsets.only(top: margin ?? 0),
      child: IgnorePointer(
        ignoring: disabled ?? false,
        child: TextButton(
          onPressed: disabled == true ? () {} : onClick,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(disabled == true ? 0x802459A9 : (color ?? 0xFF2459A9))),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 15.0),
              ),
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.only(
                top: 16,
                bottom: 16,
              ),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
