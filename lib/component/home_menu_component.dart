import 'package:flutter/material.dart';

class HomeMenuComponent extends StatelessWidget {
  final IconData icon;
  final String nama;
  final void Function()? onClick;

  const HomeMenuComponent({
    super.key,
    required this.icon,
    required this.nama,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: InkWell(
        onTap: onClick ?? () {},
        child: Ink(
          color: Colors.white,
          child: Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: Colors.green[400]),
                const SizedBox(height: 5),
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  width: 90,
                  child: Text(
                    nama,
                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w800),
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
