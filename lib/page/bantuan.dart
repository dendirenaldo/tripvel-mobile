import 'dart:convert';
import 'package:tripvel/component/faq_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BantuanPage extends StatefulWidget {
  const BantuanPage({super.key});

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> {
  late bool _isLoading;
  late List<Widget> faq;

  Future<void> getFaq() async {
    if (mounted) {
      setState(() {
        faq = [];
      });
    }
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/bantuan?order={"index":"prioritas","order":"asc"}'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<Widget> tempFaq = [];
        for (var i = 0; i < responseBody['data'].length; i++) {
          tempFaq.add(FaqComponent(
              pertanyaan: responseBody['data'][i]['pertanyaan'], jawaban: responseBody['data'][i]['jawaban']));
          tempFaq.add(const SizedBox(height: 15));
        }

        if (mounted) {
          setState(() => faq = tempFaq);
        }
      }
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void initState() {
    faq = [];
    _isLoading = true;
    getFaq();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (!_isLoading)
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
                child: Column(
                  children: faq,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
