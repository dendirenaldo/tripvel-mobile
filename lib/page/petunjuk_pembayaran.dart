import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripvel/component/transaksi_section_component.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PetunjukPembayaranPage extends StatefulWidget {
  final int id;
  final String harga;

  const PetunjukPembayaranPage({
    super.key,
    required this.id,
    required this.harga,
  });

  @override
  State<PetunjukPembayaranPage> createState() => _PetunjukPembayaranPageState();
}

class _PetunjukPembayaranPageState extends State<PetunjukPembayaranPage> {
  late bool _isLoading;
  late Map<String, dynamic>? data;
  late String accessToken;

  Future<void> getData() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/bank-account/${widget.id}"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (mounted) setState(() => data = jsonDecode(response.body));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    data = null;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        accessToken = authProvider.accessToken!;
      });
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petunjuk Pembayaran'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                TransaksiSectionComponent(
                  label: 'Pembayaran',
                  icon: Icons.attach_money_rounded,
                  widget: [
                    Text(
                      widget.harga,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2459A9)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bayarlah sesuai dengan nominal di atas',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TransaksiSectionComponent(
                  label: data != null ? data!['namaBank'] : '',
                  icon: Icons.attach_money_rounded,
                  widget: [
                    Text(
                      data != null ? data!['nomorRekening'].toString() : '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2459A9)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'a/n ${data != null ? data!['namaPemilik'] : ''}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Petunjuk Pembayaran',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: width - 60,
                      child: Html(
                        data: data != null ? data!['instruksi'] : '',
                        style: {
                          "body": Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                          "p": Style(margin: const EdgeInsets.only(bottom: 10), padding: EdgeInsets.zero),
                        },
                        onLinkTap: (url, _, __, ___) async => await launchUrl(
                          Uri.parse(url!),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
