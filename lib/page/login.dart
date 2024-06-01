// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/functionality/login_functionality.dart';
import 'package:tripvel/page/lupa_password.dart';
import 'package:tripvel/page/register.dart';
import 'package:tripvel/provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController email;
  late final TextEditingController password;
  String? emailError;
  String? passwordError;
  late bool _obscureText;
  late bool _isLoading;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> login() async {
    if (mounted) setState(() => _isLoading = true);
    await LoginFunctionality.login(context, Provider.of<AuthProvider>(context, listen: false), email.text, password.text);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    _obscureText = true;
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(50),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(Icons.error),
                            SizedBox(height: 5),
                            Text(
                              'Image not loaded',
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Selamat Datang', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LupaPasswordPage())),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Lupa Password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ButtonComponent(label: 'Masuk', onClick: login),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum Daftar?',
                          style: TextStyle(
                            color: Color(0xFF1F1F1F),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
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
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: Color(0xFF0476D6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
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
