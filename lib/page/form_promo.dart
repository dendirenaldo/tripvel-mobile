// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/provider/auth_provider.dart';

class FormPromoPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;
  final bool? isDuplicate;

  const FormPromoPage({
    super.key,
    required this.refresh,
    this.id,
    this.isDuplicate,
  });

  @override
  State<FormPromoPage> createState() => _FormPromoPageState();
}

class _FormPromoPageState extends State<FormPromoPage> {
  late final TextEditingController judul;
  late final TextEditingController deskripsi;
  late final TextEditingController tanggalBerlaku;
  late final TextEditingController tanggalBerlakuHingga;
  late final TextEditingController minimalHarga;
  String? judulError;
  String? deskripsiError;
  String? tanggalBerlakuError;
  String? tanggalBerlakuHinggaError;
  String? minimalHargaError;
  late List<dynamic> opsiPromo;
  late dynamic profile;
  late String? token;
  late bool _isLoading;

  Future<void> getPromo() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/promo/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          judul.text = responseBody['judul'];
          deskripsi.text = responseBody['deskripsi'];
          tanggalBerlaku.text = responseBody['tanggalBerlaku'];
          tanggalBerlakuHingga.text = responseBody['tanggalBerlakuHingga'] ?? '';
          minimalHarga.text = responseBody['minimalHarga'].toString();
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void getTanggal(String variableName) async {
    final TextEditingController variable = variableName == 'tanggalBerlaku' ? tanggalBerlaku : tanggalBerlakuHingga;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: variable.text != '' ? DateTime.parse(variable.text) : DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 1),
      currentDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (mounted) setState(() => variable.text = formattedDate);
    }
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    late final http.Response response;
    final Object body = jsonEncode({
      'judul': judul.text == '' ? null : judul.text,
      'deskripsi': deskripsi.text == '' ? null : deskripsi.text,
      'tanggalBerlaku': tanggalBerlaku.text == '' ? null : tanggalBerlaku.text,
      'tanggalBerlakuHingga': tanggalBerlakuHingga.text == '' ? null : tanggalBerlakuHingga.text,
      'minimalHarga': minimalHarga.text == '' ? null : minimalHarga.text,
    });

    if (widget.id != null && widget.isDuplicate != true) {
      response = await http.put(
        Uri.parse('${dotenv.env['RESTFUL_API']}/promo/${widget.id}'),
        body: body,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
    } else {
      response = await http.patch(
        Uri.parse('${dotenv.env['RESTFUL_API']}/promo'),
        body: body,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      widget.refresh();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Berhasil"),
            content: Text("Promo telah berhasil di${widget.id != null ? (widget.isDuplicate != true ? 'ubah' : 'duplikat') : 'tambahkan'}!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 400) {
      if (mounted) {
        setState(() {
          if (responseBody['judul'] != null) {
            judulError = responseBody['judul'];
          } else {
            judulError = null;
          }

          if (responseBody['deskripsi'] != null) {
            deskripsiError = responseBody['deskripsi'];
          } else {
            deskripsiError = null;
          }

          if (responseBody['tanggalBerlaku'] != null) {
            tanggalBerlakuError = responseBody['tanggalBerlaku'];
          } else {
            tanggalBerlakuError = null;
          }

          if (responseBody['tanggalBerlakuHingga'] != null) {
            tanggalBerlakuHinggaError = responseBody['tanggalBerlakuHingga'];
          } else {
            tanggalBerlakuHinggaError = null;
          }

          if (responseBody['minimalHarga'] != null) {
            minimalHargaError = responseBody['minimalHarga'];
          } else {
            minimalHargaError = null;
          }
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Gagal"),
            content: Text(responseBody['message'] ?? 'Mohon isi dengan selengkapnya dan sebenar-benarnya!'),
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

  Future<void> hapuskan() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Promo'),
          content: const Text('Apa kamu yakin ingin menghapus promo ini?'),
          actions: [
            TextButton(
              child: const Text("Ya"),
              onPressed: () {
                Navigator.of(context).pop();
                hapus();
              },
            ),
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> hapus() async {
    if (mounted) setState(() => _isLoading = true);

    final response = await http.delete(
      Uri.parse("${dotenv.env['RESTFUL_API']}/promo/${widget.id}"),
      headers: {'Authorization': 'Bearer $token'},
    );
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      widget.refresh();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Berhasil"),
            content: const Text("Promo telah berhasil dihapuskan!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
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

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    judul = TextEditingController();
    deskripsi = TextEditingController();
    tanggalBerlaku = TextEditingController();
    tanggalBerlakuHingga = TextEditingController();
    minimalHarga = TextEditingController();
    _isLoading = false;
    profile = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (mounted) {
        setState(() {
          profile = authProvider.profile!;
          token = authProvider.accessToken!;
        });
      }

      if (widget.id != null) getPromo();
    });
  }

  @override
  void dispose() {
    judul.dispose();
    deskripsi.dispose();
    tanggalBerlaku.dispose();
    tanggalBerlakuHingga.dispose();
    minimalHarga.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? (widget.isDuplicate != true ? 'Ubah' : 'Duplikat') : 'Tambah'} Promo'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
        actions: [
          if (widget.id != null && widget.isDuplicate != true)
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton<int>(
                  tooltip: 'Opsi',
                  padding: const EdgeInsets.all(8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.centerRight,
                    child: const Center(
                      child: Icon(
                        Icons.more_vert,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPromoPage(
                            refresh: widget.refresh,
                            id: widget.id,
                            isDuplicate: true,
                          ),
                        ),
                      );
                    } else if (value == 2) {
                      hapuskan();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 1,
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Colors.green),
                        minLeadingWidth: 10,
                        title: Text(
                          'Duplikat',
                          textScaleFactor: 1.0,
                        ),
                      ),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        minLeadingWidth: 10,
                        title: Text(
                          'Hapus',
                          textScaleFactor: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Silahkan isi formulir di bawah untuk me${widget.id != null && widget.isDuplicate != true ? 'ngubah' : 'nambahkan'} promo',
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 20),
                InputComponent(controller: judul, errorText: judulError, label: 'Judul'),
                const SizedBox(height: 10),
                InputComponent(controller: deskripsi, errorText: deskripsiError, label: 'Deskripsi', maxLines: 10),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ((width - 30) * 0.5) - 5,
                      child: InputComponent(
                        controller: tanggalBerlaku,
                        errorText: tanggalBerlakuError,
                        label: 'Tanggal Berlaku',
                        onTap: () => getTanggal('tanggalBerlaku'),
                        prefixIcon: Icons.calendar_month,
                      ),
                    ),
                    SizedBox(
                      width: ((width - 30) * 0.5) - 5,
                      child: InputComponent(
                        controller: tanggalBerlakuHingga,
                        errorText: tanggalBerlakuHinggaError,
                        label: 'Tanggal Berlaku (Hingga)',
                        onTap: () => getTanggal('tanggalBerlakuHingga'),
                        prefixIcon: Icons.calendar_month,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InputComponent(controller: minimalHarga, errorText: minimalHargaError, label: 'Minimal Harga', keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                ButtonComponent(label: widget.id != null ? 'Simpan' : 'Tambah', onClick: simpan),
              ],
            ),
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
      ]),
    );
  }
}
