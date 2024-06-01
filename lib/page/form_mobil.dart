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

class FormMobilPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;
  final bool? isDuplicate;

  const FormMobilPage({
    super.key,
    required this.refresh,
    this.id,
    this.isDuplicate,
  });

  @override
  State<FormMobilPage> createState() => _FormMobilPageState();
}

class _FormMobilPageState extends State<FormMobilPage> {
  late final TextEditingController travelId;
  late final TextEditingController merek;
  late final TextEditingController model;
  late final TextEditingController platNomor;
  late final TextEditingController warna;
  late final TextEditingController jumlahPenumpang;
  String? travelIdError;
  String? merekError;
  String? modelError;
  String? platNomorError;
  String? warnaError;
  String? jumlahPenumpangError;
  late List<dynamic> opsiTravel;
  late List<String> opsiJumlahPenumpang;
  late dynamic profile;
  late String? token;
  late bool _isLoading;

  Future<void> getTravel() async {
    if (mounted) {
      setState(() {
        opsiTravel = [
          {'value': '', 'label': ''}
        ];
      });
    }

    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/travel'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<dynamic> tempTravel = [];

        for (var data in responseBody['data']) {
          tempTravel.add({
            'value': data['id'].toString(),
            'label': data['nama'],
          });
        }

        if (mounted) setState(() => opsiTravel.addAll(tempTravel));
      }
    }
  }

  Future<void> getMobil() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/mobil/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          travelId.text = responseBody['travelId'].toString();
          merek.text = responseBody['merek'];
          model.text = responseBody['model'];
          if (widget.isDuplicate != true) platNomor.text = responseBody['platNomor'];
          warna.text = responseBody['warna'];
          jumlahPenumpang.text = responseBody['jumlahPenumpang'].toString();
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    late final http.Response response;
    final Object body = jsonEncode({
      'travelId': travelId.text == '' ? null : travelId.text,
      'merek': merek.text,
      'model': model.text,
      'platNomor': platNomor.text,
      'warna': warna.text,
      'jumlahPenumpang': jumlahPenumpang.text == '' || jumlahPenumpang.text == '0' ? null : jumlahPenumpang.text,
    });

    if (widget.id != null && widget.isDuplicate != true) {
      response = await http.put(
        Uri.parse('${dotenv.env['RESTFUL_API']}/mobil/${widget.id}'),
        body: body,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
    } else {
      response = await http.patch(
        Uri.parse('${dotenv.env['RESTFUL_API']}/mobil'),
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
            content: Text("Mobil telah berhasil di${widget.id != null ? (widget.isDuplicate != true ? 'ubah' : 'duplikat') : 'tambahkan'}!"),
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
          if (responseBody['travelId'] != null) {
            travelIdError = responseBody['travelId'];
          } else {
            travelIdError = null;
          }

          if (responseBody['merek'] != null) {
            merekError = responseBody['merek'];
          } else {
            merekError = null;
          }

          if (responseBody['model'] != null) {
            modelError = responseBody['model'];
          } else {
            modelError = null;
          }

          if (responseBody['platNomor'] != null) {
            platNomorError = responseBody['platNomor'];
          } else {
            platNomorError = null;
          }

          if (responseBody['warna'] != null) {
            warnaError = responseBody['warna'];
          } else {
            warnaError = null;
          }

          if (responseBody['jumlahPenumpang'] != null) {
            jumlahPenumpangError = responseBody['jumlahPenumpang'];
          } else {
            jumlahPenumpangError = null;
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
          title: const Text('Hapus Mobil'),
          content: const Text('Apa kamu yakin ingin menghapus mobil ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/mobil/${widget.id}"),
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
            content: const Text("Mobil telah berhasil dihapuskan!"),
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
    travelId = TextEditingController();
    merek = TextEditingController();
    model = TextEditingController();
    platNomor = TextEditingController();
    warna = TextEditingController();
    jumlahPenumpang = TextEditingController();
    opsiJumlahPenumpang = ['', '5', '6', '7'];
    opsiTravel = [
      {'value': '', 'label': ''}
    ];
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
      if (widget.id != null) {
        Future.wait([getTravel()]).then((_) => getMobil());
      } else {
        if (profile['role'] == 'Travel') {
          Future.wait([getTravel()]).then((_) {
            if (opsiTravel.any((item) => item['value'] == profile['travelId'].toString())) {
              travelId.text = profile['travelId'].toString();
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Gagal"),
                    content: const Text('Travel anda tidak terdaftar. Hubungi admin untuk memperbaiki data anda!'),
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
            }
          });
        } else if (profile['role'] == 'Admin') {
          getTravel();
        }
      }
    });
  }

  @override
  void dispose() {
    travelId.dispose();
    merek.dispose();
    model.dispose();
    platNomor.dispose();
    warna.dispose();
    jumlahPenumpang.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? (widget.isDuplicate != true ? 'Ubah' : 'Duplikat') : 'Tambah'} Mobil'),
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
                          builder: (context) => FormMobilPage(
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
                  'Silahkan isi formulir di bawah untuk me${widget.id != null && widget.isDuplicate != true ? 'ngubah' : 'nambahkan'} mobil',
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 20),
                SelectComponent(
                  controller: travelId,
                  errorText: travelIdError,
                  label: 'Travel',
                  opsi: opsiTravel,
                  readOnly: profile != null && profile['role']! == 'Admin' ? false : true,
                ),
                const SizedBox(height: 10),
                InputComponent(controller: merek, errorText: merekError, label: 'Merek'),
                const SizedBox(height: 10),
                InputComponent(controller: model, errorText: modelError, label: 'Model'),
                const SizedBox(height: 10),
                InputComponent(controller: platNomor, errorText: platNomorError, label: 'Plat Nomor'),
                const SizedBox(height: 10),
                InputComponent(controller: warna, errorText: warnaError, label: 'Warna'),
                const SizedBox(height: 10),
                SelectComponent(controller: jumlahPenumpang, errorText: jumlahPenumpangError, label: 'Jumlah Penumpang', opsi: opsiJumlahPenumpang),
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
