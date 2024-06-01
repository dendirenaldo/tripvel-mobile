import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TransaksiTextComponent extends StatelessWidget {
  final double width;
  final String label;
  final String text;
  final String? link;
  final void Function()? function;

  const TransaksiTextComponent({
    super.key,
    required this.width,
    required this.label,
    required this.text,
    this.link,
    this.function,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: (width - 3) / 2,
            child: Text(label, style: const TextStyle(color: Colors.black45, fontSize: 14)),
          ),
          if (link != null || function != null)
            SizedBox(
              width: (width - 3) / 2,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerRight,
                ),
                onPressed: () =>
                    function != null ? function!() : launchUrl(Uri.parse(link!), mode: LaunchMode.externalApplication),
                child: Text(text,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 14),
                    textAlign: TextAlign.right),
              ),
            )
          else
            SizedBox(
              width: (width - 3) / 2,
              child: Text(text,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14),
                  textAlign: TextAlign.right),
            )
        ],
      ),
    );
  }
}
