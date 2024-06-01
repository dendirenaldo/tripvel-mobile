// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';

class SelectComponent extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<dynamic> opsi;
  final String? errorText;
  final bool? readOnly;
  final void Function()? listen;

  const SelectComponent({
    super.key,
    required this.label,
    required this.controller,
    required this.opsi,
    this.errorText,
    this.readOnly,
    this.listen,
  });

  @override
  State<SelectComponent> createState() => _SelectComponentState();
}

class _SelectComponentState extends State<SelectComponent> {
  // DropdownMenuItem<String> opsiItem(String? item) {
  //   return DropdownMenuItem(
  //     value: item,
  //     enabled: item == '' ? false : true,
  //     child: Text(item!),
  //   );
  // }
  DropdownMenuItem<String> opsiItem(dynamic item) {
    return DropdownMenuItem(
      value: item.runtimeType == String ? item : item['value'],
      enabled: item == '' ? false : true,
      child: Text(item.runtimeType == String ? item : item['label']!, overflow: TextOverflow.ellipsis, textScaleFactor: 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 13),
          textScaleFactor: 1.0,
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: IgnorePointer(
            ignoring: widget.readOnly ?? false,
            child: DropdownButtonFormField(
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                errorText: widget.errorText,
                contentPadding: const EdgeInsets.all(12),
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
                fillColor: (widget.readOnly != null && widget.readOnly == true) ? const Color(0xFFCCCCCC) : const Color(0xFFF4F7FF),
              ),
              dropdownColor: Colors.white,
              value: widget.controller.text,
              onChanged: (String? value) {
                if (mounted) setState(() => widget.controller.text = value!);
                if (widget.listen != null) widget.listen!();
              },
              items: widget.opsi.map<DropdownMenuItem<String>>(opsiItem).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
