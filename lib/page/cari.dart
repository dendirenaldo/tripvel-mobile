import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/card/tiket_card.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/provider/pemesanan_provider.dart';

class CariPage extends StatefulWidget {
  final String from;
  final String destination;
  final String fromId;
  final String destinationId;
  final String tanggal;
  final String jumlahPenumpang;
  final String tipe;

  const CariPage({
    super.key,
    required this.from,
    required this.destination,
    required this.fromId,
    required this.destinationId,
    required this.tanggal,
    required this.jumlahPenumpang,
    required this.tipe,
  });

  @override
  State<CariPage> createState() => _CariPageState();
}

class _CariPageState extends State<CariPage> {
  late List<dynamic> listJadwal;
  late List<dynamic> listTanggal;
  late String tanggal;
  late bool _isLoading;

  Future<void> getData() async {
    if (mounted) setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.get(
      Uri.parse(
          "${dotenv.env['RESTFUL_API']}/jadwal?tanggal=$tanggal&asalId=${widget.fromId}&tujuanId=${widget.destinationId}&limit=999&offset=0&isAvailable=true&filterTipe=${widget.tipe}"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (mounted) setState(() => listJadwal = responseBody['data']);
    } else {
      if (mounted) setState(() => listJadwal = []);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void getTanggal() {
    final listDate = [];
    final selectedDate = DateTime.parse(widget.tanggal);
    final todayDate = DateTime.now();

    for (int i = -3; i <= 3; i++) {
      final date = selectedDate.add(Duration(days: i));

      if (date.isAfter(todayDate) || (date.year == todayDate.year && date.day == todayDate.day && date.month == todayDate.month)) {
        listDate.add(date.toString().substring(0, 10));
      }
    }

    if (mounted) setState(() => listTanggal.addAll(listDate));
  }

  void handleChangeTanggal(String tanggalBaru) {
    if (mounted) setState(() => tanggal = tanggalBaru);
    getData();
  }

  @override
  void initState() {
    super.initState();
    listJadwal = [];
    listTanggal = [];
    _isLoading = false;
    tanggal = widget.tanggal;
    getData();
    getTanggal();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.from} ke ${widget.destination}',
              style: const TextStyle(fontSize: 16),
              textScaleFactor: 1.0,
            ),
            Text(
              '${widget.jumlahPenumpang} Penumpang',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textScaleFactor: 1.0,
            ),
          ],
        ),
        actions: [
          SizedBox(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Text(
                'Ubah',
                style: TextStyle(color: Colors.white60),
                textScaleFactor: 1.0,
              ),
            ),
          ),
        ],
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              children: [
                if (listTanggal.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: listTanggal
                          .map(
                            (val) => InkWell(
                              onTap: () => handleChangeTanggal(val),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: val == tanggal ? const Color(0xFF2459A9) : Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Text(GeneralFunctionality.tanggalIndonesiaPendek(val, tanpaTahun: true),
                                    style: TextStyle(color: val == tanggal ? Colors.white : Colors.black)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                if (listTanggal.isNotEmpty) const SizedBox(height: 15),
                if (listJadwal.isNotEmpty)
                  ...listJadwal.map(
                    (val) => Container(
                      margin: const EdgeInsets.only(bottom: 13),
                      child: TiketCard(
                        id: val['id'],
                        width: width,
                        height: height,
                        travelId: val['travelId'],
                        travel: val['travel']['nama'],
                        tanggal: GeneralFunctionality.tanggalIndonesia(widget.tanggal),
                        asalLengkap: val['asal']['namaLengkap'],
                        asalSingkatan: val['asal']['namaSingkatan'],
                        tujuanLengkap: val['tujuan']['namaLengkap'],
                        tujuanSingkatan: val['tujuan']['namaSingkatan'],
                        jamBerangkat: val['jamBerangkat'].toString().substring(0, 5),
                        jamTiba: val['jamTiba'].toString().substring(0, 5),
                        jumlahPenumpang: int.parse(widget.jumlahPenumpang),
                        harga: val['harga'],
                      ),
                    ),
                  ),
                if (listJadwal.isEmpty) const Center(child: Text('Tidak ada jadwal')),
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
