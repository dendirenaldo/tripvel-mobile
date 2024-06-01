import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TujuanPage extends StatefulWidget {
  final int id;
  final String thumbnail;

  const TujuanPage({
    super.key,
    required this.id,
    required this.thumbnail,
  });

  @override
  State<TujuanPage> createState() => _TujuanPageState();
}

class _TujuanPageState extends State<TujuanPage> {
  bool _isLoading = true;
  String title = '';
  late String thumbnail;
  String isi = '';
  String createdAt = '';

  Future<void> getTujuan() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/tujuan/${widget.id}"),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          title = responseBody['namaLengkap'];
          thumbnail = "${dotenv.env['RESTFUL_API']}/tujuan/gambar/${widget.id}";
          isi = responseBody['deskripsi'];
          createdAt = responseBody['createdAt'];
          _isLoading = false;
        });
      }
    }
  }

  String generateTimeAgo(String? postDate) {
    if (postDate != null && postDate != '') {
      final now = DateTime.now();
      final date = DateTime.parse(postDate);
      final difference = now.difference(date);

      if (difference.inDays >= 365) {
        final years = (difference.inDays / 365).floor();
        return '$years tahun lalu';
      } else if (difference.inDays >= 30) {
        final months = (difference.inDays / 30).floor();
        return '$months bulan lalu';
      } else if (difference.inDays == 0) {
        return 'Hari ini';
      } else {
        return '${difference.inDays} hari lalu';
      }
    } else {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    getTujuan();
    thumbnail = widget.thumbnail;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tujuan'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: "tujuan${widget.id}",
                  child: Material(
                    child: Image.network(
                      thumbnail != '' ? thumbnail : "${dotenv.env['RESTFUL_API']}/tujuan/gambar/10",
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 10),
                      width: width,
                      height: width * 9 / 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(generateTimeAgo(createdAt), style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                      const SizedBox(height: 19),
                      Html(
                        data: isi,
                        style: {
                          "body": Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                          "p": Style(margin: const EdgeInsets.only(bottom: 10), padding: EdgeInsets.zero),
                        },
                        onLinkTap: (url, _, __, ___) async => await launchUrl(
                          Uri.parse(url!),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.2,
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
