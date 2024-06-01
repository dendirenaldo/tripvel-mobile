import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripvel/card/transaksi_card.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/page/login.dart';
import 'package:tripvel/provider/auth_provider.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late List<dynamic> listTransaksi;

  Future<void> getTransaksi() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi?isPast=true"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (mounted) setState(() => listTransaksi = responseBody['data']);
    }
  }

  @override
  void initState() {
    super.initState();
    listTransaksi = [];
    getTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    return Container(
      padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5, right: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...listTransaksi.map((val) {
              return Column(
                children: [
                  TransaksiCard(
                    id: val['id'],
                    travelId: val['jadwal']['travelId'],
                    travel: val['jadwal']['travel']['nama'],
                    tanggal: val['jadwal']['tanggal'],
                    asalLengkap: val['jadwal']['asal']['namaLengkap'],
                    asalSingkatan: val['jadwal']['asal']['namaSingkatan'],
                    tujuanLengkap: val['jadwal']['tujuan']['namaLengkap'],
                    tujuanSingkatan: val['jadwal']['tujuan']['namaSingkatan'],
                    jamBerangkat: val['jadwal']['jamBerangkat'].toString().substring(0, 5),
                    jamTiba: val['jadwal']['jamTiba'].toString().substring(0, 5),
                    statusPembayaran: val['statusPembayaran'],
                    jumlahPenumpang: val['jumlahTerpesan'],
                    harga: val['harga'],
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            if (listTransaksi.isEmpty) const Center(child: Text('Tidak ada transaksi')),
            const SizedBox(height: 20),
            if (authProvider.profile == null)
              ButtonComponent(
                label: 'Login',
                onClick: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
