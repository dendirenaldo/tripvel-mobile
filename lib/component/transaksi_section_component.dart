import 'package:flutter/material.dart';

class TransaksiSectionComponent extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Widget>? widget;

  const TransaksiSectionComponent({
    super.key,
    required this.label,
    required this.icon,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
          if (widget != null) ...widget!,
        ],
      ),
    );
  }
}
