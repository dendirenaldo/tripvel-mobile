// ignore_for_file: use_build_context_synchronously

import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/functionality/login_functionality.dart';
import 'package:tripvel/page/dashboard.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'dart:convert';

class LengkapiAkunPage extends StatefulWidget {
  const LengkapiAkunPage({super.key});

  @override
  State<LengkapiAkunPage> createState() => _LengkapiAkunPageState();
}

class _LengkapiAkunPageState extends State<LengkapiAkunPage> {
  late final TextEditingController password;
  late final TextEditingController nomorPonsel;
  late final TextEditingController jenisKelamin;
  String? passwordError;
  String? nomorPonselError;
  String? jenisKelaminError;
  bool obscureText = true;
  bool _isLoading = false;
  bool hasPassword = true;

  @override
  void initState() {
    password = TextEditingController();
    nomorPonsel = TextEditingController();
    jenisKelamin = TextEditingController();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    nomorPonsel.dispose();
    jenisKelamin.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    if (mounted) setState(() => obscureText = !obscureText);
  }

  void getData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final account = authProvider.getAccount();

    if (mounted) {
      setState(() {
        if (account['password'] == null) {
          hasPassword = false;
        }

        if (account['jenisKelamin'] != null) {
          jenisKelamin.text = account['jenisKelamin'];
        }

        if (account['nomorPonsel'] != null) {
          nomorPonsel.text = '${account['nomorPonsel']}';
        }
      });
    }
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.put(
      Uri.parse("${dotenv.env['RESTFUL_API']}/account/fill-profile"),
      body: jsonEncode({
        'password': password.text,
        'nomorPonsel': nomorPonsel.text,
        'jenisKelamin': jenisKelamin.text,
      }),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseCheck = await http.get(Uri.parse("${dotenv.env['RESTFUL_API']}/account/me"), headers: {'Authorization': 'Bearer $token'});
      final responseCheckBody = jsonDecode(responseCheck.body);

      if (responseCheckBody.containsKey('id')) {
        await authProvider.login(token ?? '', responseCheckBody);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Berhasil"),
            content: const Text("Informasi akun anda telah berhasil dilengkapi!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
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
          if (responseBody['password'] != null) {
            passwordError = responseBody['password'];
          } else {
            passwordError = null;
          }

          if (responseBody['nomorPonsel'] != null) {
            nomorPonselError = responseBody['nomorPonsel'];
          } else {
            nomorPonselError = null;
          }

          if (responseBody['jenisKelamin'] != null) {
            jenisKelaminError = responseBody['jenisKelamin'];
          } else {
            jenisKelaminError = null;
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
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final List<String?> opsiJenisKelamin = ['', 'Laki-Laki', 'Perempuan'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => LoginFunctionality.keluar(context, authProvider),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tekan kembali sekali lagi untuk keluar aplikasi'),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20, right: 30, left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lengkapi Profil',
                      style: TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Anda diminta untuk melengkapi seluruh entri data untuk kelengkapan profil akun Anda!',
                      style: TextStyle(
                        color: Color(0xFF4E4E4E),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (hasPassword == false)
                      InputComponent(
                        label: 'Kata Sandi',
                        controller: password,
                        obscureText: obscureText,
                        togglePasswordVisibility: _togglePasswordVisibility,
                        hintText: '*******',
                        errorText: passwordError,
                      ),
                    if (hasPassword == false) const SizedBox(height: 10),
                    SelectComponent(
                      label: 'Jenis Kelamin',
                      controller: jenisKelamin,
                      opsi: opsiJenisKelamin,
                      errorText: jenisKelaminError,
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nomor Ponsel',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                style: BorderStyle.solid,
                                color: const Color(0xFFF2F2F2),
                              ),
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xFFFBFBFB),
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            width: (MediaQuery.of(context).size.width - 65) * 0.19,
                            child: const Center(
                              child: Text(
                                '+62',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 65) * 0.8,
                            child: InputComponent(
                              hintText: 'Ex: 81234567890',
                              errorText: nomorPonselError,
                              controller: nomorPonsel,
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasPassword == false) const SizedBox(height: 10),
                    ButtonComponent(
                      label: 'Simpan',
                      onClick: simpan,
                      margin: 15,
                    ),
                  ],
                ),
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
      ),
    );
  }
}
