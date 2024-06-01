import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqComponent extends StatelessWidget {
  final String pertanyaan;
  final String jawaban;

  const FaqComponent({
    super.key,
    required this.pertanyaan,
    required this.jawaban,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(pertanyaan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        collapsedBackgroundColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFFFFFFF),
        collapsedTextColor: Colors.black,
        textColor: Colors.black,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        children: [
          Html(
            data: jawaban,
            style: {
              "body": Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
              "p": Style(margin: const EdgeInsets.only(bottom: 10), padding: EdgeInsets.zero),
            },
            onLinkTap: (url, _, __, ___) async => await launchUrl(
              Uri.parse(url!),
              mode: LaunchMode.externalApplication,
            ),
          )
        ],
      ),
    );
  }
}
