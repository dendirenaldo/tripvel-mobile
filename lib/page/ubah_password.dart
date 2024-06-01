// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  late final TextEditingController passwordLama;
  late final TextEditingController passwordBaru;
  late final TextEditingController konfirmasiPasswordBaru;
  String? passwordLamaError;
  String? passwordBaruError;
  String? konfirmasiPasswordBaruError;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    passwordLama = TextEditingController();
    passwordBaru = TextEditingController();
    konfirmasiPasswordBaru = TextEditingController();
    _isLoading = false;
  }

  @override
  void dispose() {
    passwordLama.dispose();
    passwordBaru.dispose();
    konfirmasiPasswordBaru.dispose();
    super.dispose();
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.put(
      Uri.parse("${dotenv.env['RESTFUL_API']}/account/change-password"),
      body: {
        'passwordLama': passwordLama.text,
        'passwordBaru': passwordBaru.text,
        'konfirmasiPasswordBaru': konfirmasiPasswordBaru.text,
      },
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Berhasil"),
            content: const Text("Password pada akun Anda telah berhasil diubah!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          if (responseBody['passwordLama'] != null) {
            passwordLamaError = responseBody['passwordLama'];
          } else {
            passwordLamaError = null;
          }

          if (responseBody['passwordBaru'] != null) {
            passwordBaruError = responseBody['passwordBaru'];
          } else {
            passwordBaruError = null;
          }

          if (responseBody['konfirmasiPasswordBaru'] != null) {
            konfirmasiPasswordBaruError = responseBody['konfirmasiPasswordBaru'];
          } else {
            konfirmasiPasswordBaruError = null;
          }
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Gagal"),
            content: const Text("Mohon isi dengan selengkapnya!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Silahkan isi formulir di bawah untuk mengubah password akun anda',
                    style: TextStyle(fontSize: 14, color: Colors.black45)),
                const SizedBox(height: 30),
                InputComponent(
                    controller: passwordLama,
                    obscureText: true,
                    label: 'Kata Sandi Lama',
                    hintText: '*******',
                    errorText: passwordLamaError),
                const SizedBox(height: 10),
                InputComponent(
                    controller: passwordBaru,
                    obscureText: true,
                    label: 'Kata Sandi Baru',
                    hintText: '*******',
                    errorText: passwordBaruError),
                const SizedBox(height: 10),
                InputComponent(
                    controller: konfirmasiPasswordBaru,
                    obscureText: true,
                    label: 'Konfirmasi Kata Sandi Baru',
                    hintText: '*******',
                    errorText: konfirmasiPasswordBaruError),
                const SizedBox(height: 20),
                ButtonComponent(label: 'Simpan', onClick: simpan),
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
