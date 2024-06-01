// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:tripvel/page/login.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:timer_count_down/timer_count_down.dart';

class RegisterSuccessPage extends StatefulWidget {
  const RegisterSuccessPage({super.key});

  @override
  State<RegisterSuccessPage> createState() => _RegisterSuccessPageState();
}

class _RegisterSuccessPageState extends State<RegisterSuccessPage> {
  late bool _isLoading;
  late bool _isDuration;
  late int duration;

  Future<void> sendEmailVerification() async {
    if (mounted) setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.post(
      Uri.parse("${dotenv.env['RESTFUL_API']}/account/email-verification"),
      headers: {'Authorization': 'Bearer $token'},
    );
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _isDuration = true;
          duration = (2 * 60 * 1000);
        });
      }
    } else if (response.statusCode == 400) {
      if (responseBody['email'] == 'The email has requested to activate this account. Please wait up to 2 minutes') {
        if (mounted) {
          setState(() {
            _isDuration = true;
            duration = responseBody['remaining'];
          });
        }
      }
    } else if (response.statusCode == 422 && responseBody['message'] == 'Your account is already activated!') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Peringatan"),
            content: const Text(
                "Akun Anda telah diverifikasi dan sudah bisa digunakan. Silahkan tekan tombol \"kembali\" untuk memasuki aplikasi"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _isDuration = false;
    duration = 0;
    sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            await authProvider.logout();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()), (Route<dynamic> route) => false);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(IconlyBold.send, size: 100, color: Color(0xFF555AEE)),
                const SizedBox(height: 30),
                const Text('Verifikasi Email Anda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Text(
                    'Kami telah mengirimkan link untuk aktivasi akun Anda ke email yang telah Anda daftarkan. Silahkan diperiksa dan diklik untuk mengaktifkan akun Anda',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                const Text(
                  'Tidak menerima kode?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4E4E4E),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isDuration == true)
                  Countdown(
                    seconds: (duration / 1000).round(),
                    build: (BuildContext context, double time) {
                      String waktu = '';
                      double jumlahWaktu = time;

                      if (time > 60) {
                        waktu += '${(time / 60).floor().toString()} menit ';
                        jumlahWaktu = time % 60;
                      }

                      waktu += '${jumlahWaktu.round()} detik';

                      return Text(
                        'Tunggu selama $waktu untuk request kirim ulang',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4E4E4E),
                          fontSize: 13,
                        ),
                      );
                    },
                    onFinished: () => mounted ? setState(() => _isDuration = false) : null,
                  ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: [
                    TextButton(
                        onPressed: _isDuration == true ? null : sendEmailVerification,
                        child: const Text('Kirim ulang', textAlign: TextAlign.center)),
                    TextButton(
                      onPressed: () async {
                        await authProvider.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false);
                      },
                      child: const Text('Kembali'),
                    ),
                  ],
                )
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
