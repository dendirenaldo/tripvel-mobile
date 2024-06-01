import 'package:flutter/material.dart';

class FormWizardPointComponent extends StatelessWidget {
  final bool isAngka;
  final int? angka;

  const FormWizardPointComponent({
    super.key,
    required this.isAngka,
    this.angka,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      padding: isAngka ? const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3) : const EdgeInsets.all(7.5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4C5C7B), width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        color: isAngka ? const Color(0xFF4C5C7B) : Colors.white,
      ),
      child: Center(
        child: !isAngka
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF4C5C7B),
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
              )
            : Text(angka.toString(),
                style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold)),
      ),
    );
  }
}
