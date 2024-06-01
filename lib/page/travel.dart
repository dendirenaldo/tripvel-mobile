import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TravelPage extends StatefulWidget {
  final int id;
  final String thumbnail;

  const TravelPage({
    super.key,
    required this.id,
    required this.thumbnail,
  });

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  bool _isLoading = true;
  String title = '';
  late String thumbnail;
  String isi = '';
  String createdAt = '';

  Future<void> getTravel() async {
    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/travel/${widget.id}"),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          title = responseBody['namaLengkap'];
          thumbnail = "${dotenv.env['RESTFUL_API']}/travel/gambar/${widget.id}";
          isi = responseBody['deskripsi'];
          createdAt = responseBody['createdAt'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getTravel();
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
        title: const Text('Travel', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.black,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: getTravel,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.black,
              size: 30,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: "travel${widget.id}",
                  child: Material(
                    child: Image.network(
                      thumbnail != '' ? thumbnail : "${dotenv.env['RESTFUL_API']}/travel/gambar/10",
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) =>
                          const Icon(Icons.error, size: 10),
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
