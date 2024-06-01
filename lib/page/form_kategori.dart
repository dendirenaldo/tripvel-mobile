// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:tripvel/provider/auth_provider.dart';

class FormKategoriPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;
  final bool? isDuplicate;

  const FormKategoriPage({
    super.key,
    required this.refresh,
    this.id,
    this.isDuplicate,
  });

  @override
  State<FormKategoriPage> createState() => _FormKategoriPageState();
}

class _FormKategoriPageState extends State<FormKategoriPage> {
  late final TextEditingController nama;
  String? namaError;
  late dynamic profile;
  late String? token;
  late bool _isLoading;

  Future<void> getKategori() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/kategori/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          nama.text = responseBody['nama'];
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    late final http.Response response;
    final Object body = jsonEncode({
      'nama': nama.text,
    });

    if (widget.id != null && widget.isDuplicate != true) {
      response = await http.put(
        Uri.parse('${dotenv.env['RESTFUL_API']}/kategori/${widget.id}'),
        body: body,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
    } else {
      response = await http.patch(
        Uri.parse('${dotenv.env['RESTFUL_API']}/kategori'),
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
            content: Text("Kategori telah berhasil di${widget.id != null ? (widget.isDuplicate != true ? 'ubah' : 'duplikat') : 'tambahkan'}!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);

                  if (widget.isDuplicate == true) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 400) {
      if (mounted) {
        setState(() {
          if (responseBody['nama'] != null) {
            namaError = responseBody['nama'];
          } else {
            namaError = null;
          }
        });
      }

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
          title: const Text('Hapus Kategori'),
          content: const Text('Apa kamu yakin ingin menghapus kategori ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/kategori/${widget.id}"),
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
            content: const Text("Kategori telah berhasil dihapuskan!"),
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
    nama = TextEditingController();
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

      if (widget.id != null) getKategori();
    });
  }

  @override
  void dispose() {
    nama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? (widget.isDuplicate != true ? 'Ubah' : 'Duplikat') : 'Tambah'} Kategori'),
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
                          builder: (context) => FormKategoriPage(
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
                  'Silahkan isi formulir di bawah untuk me${widget.id != null && widget.isDuplicate != true ? 'ngubah' : 'nambahkan'} kategori',
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 20),
                InputComponent(controller: nama, errorText: namaError, label: 'Nama'),
                const SizedBox(height: 20),
                ButtonComponent(label: widget.id != null && widget.isDuplicate != true ? 'Simpan' : 'Tambah', onClick: simpan),
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
