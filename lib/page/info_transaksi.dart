// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/transaksi_section_component.dart';
import 'package:tripvel/component/transaksi_text_component.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/page/petunjuk_pembayaran.dart';
import 'package:tripvel/page/rute_penjemputan.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class InfoTransaksiPage extends StatefulWidget {
  final int id;
  const InfoTransaksiPage({
    super.key,
    required this.id,
  });

  @override
  State<InfoTransaksiPage> createState() => _InfoTransaksiPageState();
}

class _InfoTransaksiPageState extends State<InfoTransaksiPage> {
  late Map<String, dynamic>? data;
  late final String accessToken;
  late bool _isLoading;
  late bool _isAbleToBatal;
  XFile? buktiPembayaran;
  CroppedFile? croppedBuktiPembayaran;
  late dynamic profile;

  Future<void> getData() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi/${widget.id}"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (mounted) setState(() => data = jsonDecode(response.body));

      if (data != null && data!['statusPenjemputan'] == null) {
        if (profile['role'] == 'Admin' || profile['role'] == 'Travel' && data!['statusPembayaran'] != 'Lunas') {
          _isAbleToBatal = true;
        } else if (profile['role'] == 'Penumpang' && data!['metodePembayaran'] == 'Tunai') {
          _isAbleToBatal = false;
        } else {
          _isAbleToBatal = false;
        }
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void batalkan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Batalkan"),
          content: const Text("Apa kamu yakin ingin membatalkan pesanan Anda?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: batalkanPemesanan,
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  Future<void> batalkanPemesanan() async {
    if (mounted) setState(() => _isLoading = true);
    Navigator.of(context).pop();
    final response = await http.put(
      Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi/batalkan/${widget.id}"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (mounted) setState(() => data = responseBody);
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

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (mounted) setState(() => buktiPembayaran = pickedFile);
    await _cropImage();
  }

  Future<void> _cropImage() async {
    if (buktiPembayaran != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: buktiPembayaran!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 65,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Gambar',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Gambar'),
        ],
      );

      if (croppedFile != null) {
        if (mounted) setState(() => croppedBuktiPembayaran = croppedFile);
        _ubahBuktiPembayaran();
      }
    }
  }

  Future<void> _ubahBuktiPembayaran() async {
    if (croppedBuktiPembayaran != null) {
      var request = http.MultipartRequest('PUT', Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi/bukti-pembayaran/${widget.id}"));
      request.headers.addAll({"Authorization": "Bearer $accessToken"});
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedBuktiPembayaran!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        getData();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Berhasil"),
              content: const Text("Bukti pembayaran berhasil diunggah!"),
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(jsonDecode(response.body)['message'] ?? ''),
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
  }

  List<Widget> listPenumpang() {
    int urutan = 1;
    List<Widget> tempPenumpang = [];

    if (data != null && data!['transaksiList'] != null && data!['transaksiList'].isNotEmpty) {
      for (var val in data!['transaksiList']) {
        tempPenumpang.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${urutan.toString()}.',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15), textScaleFactor: 1.0),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penumpang: ${val['namaLengkap']}'),
                const SizedBox(height: 3),
                Text('Kursi: ${val['nomorKursi']}'),
              ],
            ),
          ],
        ));
      }
    }

    return tempPenumpang;
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _isAbleToBatal = false;
    data = null;
    profile = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        profile = authProvider.profile;
        accessToken = authProvider.accessToken!;
      });
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Pemesanan'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                TransaksiSectionComponent(
                  label: 'Pembayaran',
                  icon: Icons.attach_money_rounded,
                  widget: [
                    TransaksiTextComponent(
                        width: width - 20,
                        label: 'Metode Pembayaran',
                        text: data != null
                            ? (data!['metodePembayaran'] == 'Transfer' ? 'Transfer (${data!['bankAccount']['namaBank']})' : data!['metodePembayaran'])
                            : ''),
                    const SizedBox(height: 8),
                    TransaksiTextComponent(
                        width: width - 20,
                        label: 'Tanggal Pembayaran',
                        text: data != null
                            ? '${GeneralFunctionality.tanggalIndonesia(data!['createdAt'])} ${data!['createdAt'].substring(11, 16)}'
                            : ''),
                    const SizedBox(height: 8),
                    TransaksiTextComponent(width: width - 20, label: 'Status Pembayaran', text: data != null ? data!['statusPembayaran'] : ''),
                    const SizedBox(height: 8),
                    TransaksiTextComponent(
                        width: width - 20, label: 'Harga (per tiket)', text: data != null ? 'Rp${GeneralFunctionality.rupiah(data!['harga'])}' : ''),
                    const SizedBox(height: 8),
                    TransaksiTextComponent(
                        width: width - 20, label: 'Diskon', text: data != null ? 'Rp${GeneralFunctionality.rupiah(data!['diskon'] ?? 0)}' : ''),
                    const SizedBox(height: 8),
                    TransaksiTextComponent(
                        width: width - 20,
                        label: 'Biaya Layanan',
                        text: data != null ? 'Rp${GeneralFunctionality.rupiah(data!['biayaLayanan'] ?? 0)}' : ''),
                    const SizedBox(height: 8),
                    TransaksiTextComponent(
                        width: width - 20,
                        label: 'Total Pembayaran',
                        text: data != null
                            ? 'Rp${GeneralFunctionality.rupiah(((data!['harga'] * data!['transaksiList'].length) + (data!['biayaLayanan'] ?? 0)) - (data!['diskon'] ?? 0))}'
                            : ''),
                    if (data != null && data!['statusPembayaran'] == 'Belum Lunas' && data!['metodePembayaran'] == 'Transfer')
                      const SizedBox(height: 8),
                    if (data != null && data!['statusPembayaran'] == 'Belum Lunas' && data!['metodePembayaran'] == 'Transfer')
                      TransaksiTextComponent(
                          width: width - 20,
                          label: 'Petunjuk Pembayaran',
                          text: 'Lihat petunjuk',
                          link: '${dotenv.env['RESTFUL_API']}/transaksi/bukti-pembayaran/${data!['buktiPembayaran']}',
                          function: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetunjukPembayaranPage(
                                    id: data!['bankAccountId'],
                                    harga: 'Rp${GeneralFunctionality.rupiah(data!['harga'] * data!['transaksiList'].length)}'),
                              ),
                            );
                          }),
                    if (data != null && data!['buktiPembayaran'] != null) const SizedBox(height: 8),
                    if (data != null && data!['buktiPembayaran'] != null)
                      TransaksiTextComponent(
                        width: width - 20,
                        label: 'Bukti Pembayaran',
                        text: 'Lihat bukti',
                        link: '${dotenv.env['RESTFUL_API']}/transaksi/bukti-pembayaran/${data!['buktiPembayaran']}',
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                TransaksiSectionComponent(label: 'Pemesanan', icon: Icons.task, widget: [
                  TransaksiTextComponent(width: width - 20, label: 'Asal', text: data != null ? data!['jadwal']['asal']['namaLengkap'] : ''),
                  const SizedBox(height: 8),
                  TransaksiTextComponent(width: width - 20, label: 'Tujuan', text: data != null ? data!['jadwal']['tujuan']['namaLengkap'] : ''),
                  const SizedBox(height: 8),
                  TransaksiTextComponent(width: width - 20, label: 'Tipe', text: data != null ? data!['jadwal']['tipe'] : ''),
                  const SizedBox(height: 8),
                  TransaksiTextComponent(
                      width: width - 20,
                      label: 'Tanggal',
                      text: data != null ? GeneralFunctionality.tanggalIndonesia(data!['jadwal']['tanggal']) : ''),
                  const SizedBox(height: 8),
                  TransaksiTextComponent(
                      width: width - 20, label: 'Pergi', text: data != null ? data!['jadwal']['jamBerangkat'].substring(0, 5) : ''),
                  const SizedBox(height: 8),
                  TransaksiTextComponent(
                      width: width - 20, label: 'Tiba (estimasi)', text: data != null ? data!['jadwal']['jamTiba'].substring(0, 5) : ''),
                  const SizedBox(height: 8),
                  TransaksiTextComponent(
                      width: width - 20,
                      label: 'Mobil',
                      text: data != null
                          ? '${data!['jadwal']['mobil']['merek']} ${data!['jadwal']['mobil']['model']} (${data!['jadwal']['mobil']['platNomor']})'
                          : ''),
                  if (data != null && data!['statusPembayaran'] == 'Lunas') const SizedBox(height: 8),
                  if (data != null && data!['statusPembayaran'] == 'Lunas')
                    TransaksiTextComponent(width: width - 20, label: 'Status Pemesanan', text: data != null ? data!['statusPenjemputan'] : ''),
                ]),
                const SizedBox(height: 15),
                TransaksiSectionComponent(
                  label: 'Penumpang',
                  icon: Icons.people_alt_rounded,
                  widget: listPenumpang(),
                ),
                const SizedBox(height: 15),
                if (data != null && data!['statusPembayaran'] == 'Belum Lunas' && data!['metodePembayaran'] == 'Transfer')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ButtonComponent(
                      label: 'Unggah Bukti Pembayaran',
                      onClick: _getFromCamera,
                    ),
                  ),
                if (data != null && data!['statusPembayaran'] == 'Belum Lunas' && data!['metodePembayaran'] == 'Transfer') const SizedBox(height: 10),
                if (_isAbleToBatal == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ButtonComponent(
                      label: 'Batalkan Pemesanan',
                      onClick: batalkan,
                      color: 0xFFFF0000,
                    ),
                  ),
                if (_isAbleToBatal == true) const SizedBox(height: 10),
                if (data != null && data!['statusPembayaran'] == 'Lunas' && data!['statusPenjemputan'] == 'Sedang dalam Perjalanan')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ButtonComponent(
                      label: 'Lihat Penjemputan',
                      onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RutePenjemputanPage(id: widget.id))),
                    ),
                  ),
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
