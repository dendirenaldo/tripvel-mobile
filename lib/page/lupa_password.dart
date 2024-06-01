import 'package:flutter/material.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/page/login.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  late final TextEditingController email;
  String? emailError;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Permintaan Atur Ulang Password',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                      'Silahkan isi formulir di bawah dengan benar untuk mengajukan permintaan atur ulang password anda',
                      style: TextStyle(fontSize: 14, color: Colors.black45)),
                  const SizedBox(height: 30),
                  InputComponent(controller: email, label: 'Email Address', hintText: 'Ex: dani@gmail.com'),
                  const SizedBox(height: 20),
                  ButtonComponent(label: 'Kirim', onClick: () {}),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah ingat kata sandinya?',
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
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
