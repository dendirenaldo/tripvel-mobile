import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tripvel/page/dashboard.dart';
import 'package:tripvel/page/lengkapi_akun.dart';
import 'package:tripvel/page/login.dart';
import 'package:tripvel/page/register_success.dart';
import 'package:tripvel/page/root.dart';
import 'dart:convert';

import 'package:tripvel/provider/auth_provider.dart';

class LoginFunctionality {
  static Future<void> login(context, AuthProvider authProvider, String email, String password, {bool isRegistration = false}) async {
    final response = await http.post(
      Uri.parse("${dotenv.env['RESTFUL_API']}/auth/login"),
      body: {
        'email': email,
        'password': password,
      },
    );

    final responseBody = jsonDecode(response.body);
    String? token = responseBody['access_token'];

    if (response.statusCode == 201) {
      if (token != null) {
        final responseCheck = await http.get(Uri.parse("${dotenv.env['RESTFUL_API']}/account/me"), headers: {'Authorization': 'Bearer $token'});
        final responseCheckBody = jsonDecode(responseCheck.body);

        if (responseCheckBody.containsKey('id')) {
          await authProvider.login(token, responseCheckBody).then((_) {
            if (responseCheckBody['isActive'] == false) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RegisterSuccessPage()),
                (Route<dynamic> route) => false,
              );
            } else if (responseCheckBody['role'] == 'Pengguna' &&
                (responseCheckBody['jenisKelamin'] == null || responseCheckBody['nomorPonsel'] == null)) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LengkapiAkunPage()),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
                (Route<dynamic> route) => false,
              );
            }
          });
        }
      }
    } else if (response.statusCode == 400) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Gagal"),
            content: const Text("Mohon isi dengan selengkapnya dan sebenar-benarnya!"),
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
    } else if (response.statusCode == 403) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Gagal"),
            content: const Text("Email atau password yang Anda masukkan salah!"),
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
  }

  static void keluar(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Keluar"),
          content: const Text("Apa kamu yakin ingin keluar dari akun Anda?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Ya"),
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                  (route) => false,
                );
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        );
      },
    );
  }
}
