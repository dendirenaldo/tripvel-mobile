import 'package:flutter/material.dart';

class SettingComponent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? hint;
  final void Function()? onClick;

  const SettingComponent({
    super.key,
    required this.label,
    required this.icon,
    this.hint,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onClick,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(50),
                  elevation: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Icon(icon, size: 21, color: const Color(0xFFFF8A3C)),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (hint != null) const SizedBox(height: 10),
                    if (hint != null)
                      Text(
                        hint ?? '',
                        style: const TextStyle(
                          color: Color(0xFF6F767E),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
