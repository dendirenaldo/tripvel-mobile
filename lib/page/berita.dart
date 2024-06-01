import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BeritaPage extends StatefulWidget {
  final int id;
  final String thumbnail;

  const BeritaPage({
    super.key,
    required this.id,
    required this.thumbnail,
  });

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  bool _isLoading = true;
  String title = '';
  String authorImage = '';
  String authorName = '';
  late String thumbnail;
  String isi = '';
  String createdAt = '';
  int waktuMembaca = 0;

  Future<void> getBerita() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/berita/${widget.id}"),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          title = responseBody['judul'];
          thumbnail = "${dotenv.env['RESTFUL_API']}/berita/gambar/${widget.id}";
          authorName = "${responseBody['auth']['namaLengkap']}";
          authorImage = "${dotenv.env['RESTFUL_API']}/auth/gambar/${responseBody['auth']['id']}";
          isi = responseBody['isi'];
          waktuMembaca = responseBody['waktuMembaca'];
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
    getBerita();
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
        title: const Text('Berita'),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 170,
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.network(
                                authorImage != '' ? authorImage : "${dotenv.env['RESTFUL_API']}/auth/gambar/1",
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 10),
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: Text(
                                authorName != '' ? authorName : '',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Hero(
                  tag: "berita${widget.id}",
                  child: Material(
                    child: Image.network(
                      thumbnail != '' ? thumbnail : "${dotenv.env['RESTFUL_API']}/berita/gambar/10",
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
                      Row(
                        children: [
                          Text(generateTimeAgo(createdAt), style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(fontSize: 15, color: Color(0xFF999999))),
                          const SizedBox(width: 8),
                          Text("$waktuMembaca menit", style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                        ],
                      ),
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
