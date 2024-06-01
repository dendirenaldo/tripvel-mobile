// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';
import 'package:http/http.dart' as http;

class FillTransaksiPage extends StatefulWidget {
  final int id;
  final int harga;
  final int jumlahPenumpang;
  final String placeName;
  final double latitude;
  final double longitude;

  const FillTransaksiPage({
    super.key,
    required this.id,
    required this.harga,
    required this.jumlahPenumpang,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<FillTransaksiPage> createState() => _FillTransaksiPageState();
}

class _FillTransaksiPageState extends State<FillTransaksiPage> {
  late List<TextEditingController> kursiController;
  late TextEditingController alamatTambahanController;
  late String metodePembayaran;
  late List<dynamic> listMetodePembayaran;
  late bool _isLoading;

  void setController() {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: false);

    for (var _ in pemesananProvider.listKursi) {
      if (mounted) setState(() => kursiController.add(TextEditingController()));
      print(kursiController[0].text);
    }
  }

  Future<void> getMetodePembayaran() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/bank-account"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (mounted) setState(() => listMetodePembayaran = responseBody['data']);
    } else {
      if (mounted) setState(() => listMetodePembayaran = []);
    }
  }

  Future<void> bayar() async {
    int error = 0;

    for (var val in kursiController) {
      if (val.text == '') {
        error++;
      }
    }

    if (metodePembayaran == '') error++;
    if (alamatTambahanController.text == '') error++;
    if (mounted) setState(() => _isLoading = true);

    if (error > 0) {
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
    } else {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final pemesananProvider = Provider.of<PemesananProvider>(context, listen: false);
      final token = authProvider.accessToken;
      final response = await http.patch(
        Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi"),
        body: jsonEncode({
          'jadwalId': widget.id,
          'bankAccountId': metodePembayaran != 'Tunai' ? metodePembayaran : null,
          'metodePembayaran': metodePembayaran == 'Tunai' ? 'Tunai' : 'Transfer',
          'harga': (widget.harga * widget.jumlahPenumpang) + 500,
          'alamatTambahan': alamatTambahanController.text,
          'latitude': widget.latitude,
          'longitude': widget.longitude,
          'alamat': widget.placeName,
          'transaksiList': pemesananProvider.listKursi.asMap().entries.map((entry) {
            final index = entry.key;
            final val = entry.value;
            return {'nomorKursi': val, 'namaLengkap': kursiController[index].text};
          }).toList(),
        }),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Berhasil"),
              content: const Text("Travel berhasil dipesan! Silahkan lakukan pembayaran"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Gagal"),
              content: Text(responseBody['message']),
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

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    kursiController = [];
    alamatTambahanController = TextEditingController();
    listMetodePembayaran = [];
    _isLoading = false;
    metodePembayaran = 'Tunai';

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setController();
      getMetodePembayaran();
    });
  }

  @override
  void dispose() {
    kursiController.map((val) => val.dispose());
    alamatTambahanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: true);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proses Order'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 165),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kursiController.isNotEmpty)
                    const Text('Informasi Penumpang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Use the index here
                  if (kursiController.isNotEmpty) const SizedBox(height: 15),
                  if (kursiController.isNotEmpty)
                    ...pemesananProvider.listKursi.asMap().entries.map((entry) {
                      final index = entry.key;
                      final val = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputComponent(
                            controller: kursiController[index],
                            label: 'Nama Penumpang Kursi $val',
                            hintText: 'Ex. Doddy Suganda',
                          ),
                        ],
                      );
                    }).toList(),
                  const SizedBox(height: 20),
                  const Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity,
                              ),
                              activeColor: MaterialStateColor.resolveWith((states) => Colors.orange),
                              value: metodePembayaran == 'Tunai' ? 1 : 0,
                              groupValue: 1,
                              onChanged: (value) {
                                if (mounted) setState(() => metodePembayaran = 'Tunai');
                              },
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                if (mounted) setState(() => metodePembayaran = 'Tunai');
                              },
                              child: const Text('Tunai (Rupiah)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textScaleFactor: 1.0),
                            ),
                          ],
                        ),
                        const Icon(Icons.attach_money_rounded, size: 21),
                      ],
                    ),
                  ),
                  ...listMetodePembayaran.map(
                    (val) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Radio(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                activeColor: MaterialStateColor.resolveWith((states) => Colors.orange),
                                value: metodePembayaran == val['id'].toString() ? 1 : 0,
                                groupValue: 1,
                                onChanged: (value) {
                                  if (mounted) setState(() => metodePembayaran = val['id'].toString());
                                },
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  if (mounted) setState(() => metodePembayaran = val['id'].toString());
                                },
                                child: Text(val['namaBank'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textScaleFactor: 1.0),
                              ),
                            ],
                          ),
                          Image.network(
                            '${dotenv.env['RESTFUL_API']}/bank-account/gambar/${val['id']}',
                            height: 20,
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Alamat Lengkap (Tambahan)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  InputComponent(
                    controller: alamatTambahanController,
                    hintText: 'Ex. Jalan Darma No. 10, Kel. Taman Wisata, Kec. Bapenas',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Harga Tiket per Orang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                      Text('IDR ${GeneralFunctionality.rupiah(widget.harga)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya Layanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                      Text('IDR ${GeneralFunctionality.rupiah(500)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                      Text('IDR ${GeneralFunctionality.rupiah((widget.harga * widget.jumlahPenumpang) + 500)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ButtonComponent(label: 'Bayar', onClick: bayar, width: width - 30),
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
