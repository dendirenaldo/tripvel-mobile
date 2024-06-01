// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:tripvel/functionality/login_functionality.dart';
import 'package:tripvel/page/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/provider/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController namaLengkap;
  late final TextEditingController nomorPonsel;
  late final TextEditingController jenisKelamin;
  String? emailError;
  String? passwordError;
  String? namaLengkapError;
  String? nomorPonselError;
  String? jenisKelaminError;
  late bool _obscureText;
  late bool _isLoading;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> registrasi(BuildContext context, AuthProvider authProvder) async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.patch(
      Uri.parse("${dotenv.env['RESTFUL_API']}/auth/register"),
      body: {
        'email': email.text,
        'password': password.text,
        'namaLengkap': namaLengkap.text,
        'nomorPonsel': nomorPonsel.text,
        'jenisKelamin': jenisKelamin.text,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return await LoginFunctionality.login(context, authProvder, email.text, password.text, isRegistration: true);
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          if (responseBody['email'] != null) {
            emailError = responseBody['email'];
          } else {
            emailError = null;
          }

          if (responseBody['password'] != null) {
            passwordError = responseBody['password'];
          } else {
            passwordError = null;
          }

          if (responseBody['namaLengkap'] != null) {
            namaLengkapError = responseBody['namaLengkap'];
          } else {
            namaLengkapError = null;
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

  Future<void> test() async {
    // return NULL;
  }

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    namaLengkap = TextEditingController();
    nomorPonsel = TextEditingController();
    jenisKelamin = TextEditingController();
    _obscureText = true;
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    namaLengkap.dispose();
    nomorPonsel.dispose();
    jenisKelamin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String?> opsiJenisKelamin = ['', 'Laki-Laki', 'Perempuan'];
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pendaftaran Akun Baru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Silahkan isi formulir di bawah dengan benar untuk membuat akun anda',
                      style: TextStyle(fontSize: 14, color: Colors.black45)),
                  const SizedBox(height: 30),
                  InputComponent(
                    controller: email,
                    label: 'Email Address',
                    hintText: 'Ex: dani@gmail.com',
                    errorText: emailError,
                  ),
                  const SizedBox(height: 10),
                  InputComponent(
                    controller: password,
                    label: 'Kata Sandi',
                    hintText: '*******',
                    errorText: passwordError,
                    obscureText: _obscureText,
                    togglePasswordVisibility: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 10),
                  InputComponent(
                    controller: namaLengkap,
                    label: 'Nama Lengkap',
                    hintText: 'Ex: Dani Hidayat',
                    errorText: namaLengkapError,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nomor Ponsel',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFF4F7FF),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: (MediaQuery.of(context).size.width - 65) * 0.19,
                          child: const Center(child: Text('+62', style: TextStyle(fontSize: 16))),
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
                  const SizedBox(height: 10),
                  SelectComponent(
                    label: 'Jenis Kelamin',
                    controller: jenisKelamin,
                    opsi: opsiJenisKelamin,
                    errorText: jenisKelaminError,
                  ),
                  const SizedBox(height: 30),
                  ButtonComponent(label: 'Daftar', onClick: () => registrasi(context, authProvider)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah memiliki akun?',
                        style: TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.only(
                              left: 6,
                            ),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: MaterialStateProperty.all(const Size(5, 5)),
                        ),
                        child: const Text(
                          'Masuk Sekarang',
                          style: TextStyle(
                            color: Color(0xFF0476D6),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
    );
  }
}
