import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripvel/page/dashboard.dart';
import 'package:tripvel/page/lengkapi_akun.dart';
import 'package:tripvel/page/login.dart';
import 'package:tripvel/page/register_success.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/screen/splash.dart';
import 'package:http/http.dart' as http;

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  Future<Widget> splashWait() async {
    return Future.delayed(const Duration(seconds: 0), checkLogin);
  }

  Future<Widget> checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    // final isFirstTime = prefs.getString('is_first_time');

    // if (isFirstTime == null) {
    //   return const OnboardPage();
    // } else {
    if (token != null) {
      final response = await http.get(
        Uri.parse("${dotenv.env['RESTFUL_API']}/account/me"),
        headers: {'Authorization': 'Bearer $token'},
      );
      final responseBody = jsonDecode(response.body);

      if (responseBody.containsKey('id')) {
        return await authProvider.login(token, responseBody).then((_) {
          if (responseBody['isActive'] == false) {
            return const RegisterSuccessPage();
          } else if (responseBody['role'] == 'Pengguna' && (responseBody['jenisKelamin'] == null || responseBody['nomorPonsel'] == null)) {
            return const LengkapiAkunPage();
          } else {
            return const DashboardPage();
          }
        });
      }
    }

    // authProvider.logout();
    return const DashboardPage();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: splashWait(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Center(
            child: LoginPage(),
          );
        }
      },
    );
  }
}
