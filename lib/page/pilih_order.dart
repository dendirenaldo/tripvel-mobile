import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/card/tiket_card.dart';
import 'package:tripvel/page/fill_transaksi.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';
import 'package:tripvel/screen/enam_penumpang.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/screen/lima_penumpang.dart';
import 'package:tripvel/screen/tujuh_penumpang.dart';

class PilihOrderPage extends StatefulWidget {
  final int id;
  final int travelId;
  final String travel;
  final String tanggal;
  final String asalSingkatan;
  final String asalLengkap;
  final String tujuanSingkatan;
  final String tujuanLengkap;
  final String jamBerangkat;
  final String jamTiba;
  final int jumlahPenumpang;
  final int harga;
  final String placeName;
  final double latitude;
  final double longitude;

  const PilihOrderPage({
    super.key,
    required this.id,
    required this.travelId,
    required this.travel,
    required this.tanggal,
    required this.asalSingkatan,
    required this.asalLengkap,
    required this.tujuanSingkatan,
    required this.tujuanLengkap,
    required this.jamBerangkat,
    required this.jamTiba,
    required this.jumlahPenumpang,
    required this.harga,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PilihOrderPage> createState() => _PilihOrderPageState();
}

class _PilihOrderPageState extends State<PilihOrderPage> {
  late bool _isLoading;
  late int kapasitasPenumpang;
  late List<dynamic> listTerisi;

  Future<void> getJadwal() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.get(
      Uri.parse(
        '${dotenv.env['RESTFUL_API']}/jadwal/${widget.id}',
      ),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      List<dynamic> tempTerisi = [];
      if (responseBody['kursiTerisi'].isNotEmpty) tempTerisi = responseBody['kursiTerisi'].map((val) => val['nomorKursi']).toList();

      for (var val in responseBody['transaksi']) {
        if (val['statusPembayaran'] != 'Batal') {
          for (var vals in val['transaksiList']) {
            tempTerisi.add(vals['nomorKursi']);
          }
        }
      }

      if (mounted) {
        setState(() {
          kapasitasPenumpang = responseBody['mobil']['jumlahPenumpang'];
          listTerisi = tempTerisi;
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    listTerisi = [];
    kapasitasPenumpang = 0;
    getJadwal();
  }

  @override
  Widget build(BuildContext context) {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: true);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Order'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
        actions: [
          if (pemesananProvider.listKursi.length == widget.jumlahPenumpang)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FillTransaksiPage(
                    id: widget.id,
                    harga: widget.harga,
                    jumlahPenumpang: widget.jumlahPenumpang,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    placeName: widget.placeName,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.check_rounded,
                size: 30,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TiketCard(
                  id: widget.id,
                  width: width,
                  height: height,
                  travelId: widget.travelId,
                  travel: widget.travel,
                  tanggal: widget.tanggal,
                  asalSingkatan: widget.asalSingkatan,
                  asalLengkap: widget.asalLengkap,
                  tujuanSingkatan: widget.tujuanSingkatan,
                  tujuanLengkap: widget.tujuanLengkap,
                  jamBerangkat: widget.jamBerangkat,
                  jamTiba: widget.jamTiba,
                  jumlahPenumpang: widget.jumlahPenumpang,
                  harga: widget.harga,
                  isOrder: true,
                ),
                const SizedBox(height: 25),
                const Text('Tempat Duduk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (kapasitasPenumpang == 7)
                  TujuhPenumpangScreen(jumlahPenumpang: widget.jumlahPenumpang, listTerisi: listTerisi, width: width)
                else if (kapasitasPenumpang == 6)
                  EnamPenumpangScreen(jumlahPenumpang: widget.jumlahPenumpang, listTerisi: listTerisi)
                else if (kapasitasPenumpang == 5)
                  LimaPenumpangScreen(jumlahPenumpang: widget.jumlahPenumpang, listTerisi: listTerisi, width: width),
                const SizedBox(height: 10),
                const Text('Keterangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Material(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      elevation: 2,
                      child: Container(
                        height: 25,
                        width: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Belum terisi')
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Material(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      elevation: 2,
                      child: Container(
                        height: 25,
                        width: 25,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Terisi')
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Material(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      elevation: 2,
                      child: Container(
                        height: 25,
                        width: 25,
                        color: const Color(0xFF2459A9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Dipilih')
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.2,
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
