// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:tripvel/provider/auth_provider.dart';

class FormBeritaPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;

  const FormBeritaPage({
    super.key,
    required this.refresh,
    this.id,
  });

  @override
  State<FormBeritaPage> createState() => _FormBeritaPageState();
}

class _FormBeritaPageState extends State<FormBeritaPage> {
  late final TextEditingController judul;
  late final TextEditingController isi;
  late final TextEditingController deskripsi;
  late final TextEditingController waktuMembaca;
  late final TextEditingController kategoriId;
  String? gambarBerita;
  String? gambarError;
  String? judulError;
  String? isiError;
  String? deskripsiError;
  String? waktuMembacaError;
  String? kategoriIdError;
  late List<dynamic> opsiKategori;
  late dynamic profile;
  late String? token;
  late bool _isLoading;
  XFile? gambar;
  CroppedFile? croppedGambar;

  Future<void> _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (mounted) setState(() => gambar = pickedFile);
    await _cropImage();
  }

  Future<void> _cropImage() async {
    if (gambar != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: gambar!.path,
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
        if (mounted) setState(() => croppedGambar = croppedFile);
        gambarBerita = null;
      }
    }
  }

  Future<void> getKategori() async {
    if (mounted) {
      setState(() {
        opsiKategori = [
          {'value': '', 'label': ''}
        ];
      });
    }

    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/kategori'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<dynamic> tempMobil = [];

        for (var data in responseBody['data']) {
          tempMobil.add({
            'value': data['id'].toString(),
            'label': data['nama'],
          });
        }

        if (mounted) setState(() => opsiKategori.addAll(tempMobil));
      }
    }
  }

  Future<void> getBerita() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/berita/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          gambarBerita = '${dotenv.env['RESTFUL_API']}/berita/gambar/${responseBody['id']}';
          judul.text = responseBody['judul'];
          isi.text = responseBody['isi'];
          waktuMembaca.text = responseBody['waktuMembaca'].toString();
          kategoriId.text = responseBody['kategoriId'].toString();
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    var request = http.MultipartRequest(
        widget.id != null ? 'PUT' : 'PATCH', Uri.parse("${dotenv.env['RESTFUL_API']}/berita${widget.id != null ? '/${widget.id}' : ''}"));
    request.headers.addAll({"Authorization": "Bearer $token"});

    if (croppedGambar != null) {
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedGambar!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
    }

    request.fields['judul'] = judul.text;
    request.fields['isi'] = isi.text;
    request.fields['deskripsi'] = deskripsi.text;
    request.fields['waktuMembaca'] = waktuMembaca.text;
    if (kategoriId.text != '') request.fields['kategoriId'] = kategoriId.text;
    final streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      widget.refresh();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Berhasil"),
            content: Text("Berita telah berhasil di${widget.id != null ? 'ubah' : 'tambahkan'}!"),
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

          if (responseBody['isi'] != null) {
            isiError = responseBody['isi'];
          } else {
            isiError = null;
          }

          if (responseBody['deskripsi'] != null) {
            deskripsiError = responseBody['deskripsi'];
          } else {
            deskripsiError = null;
          }

          if (responseBody['waktuMembaca'] != null) {
            waktuMembacaError = responseBody['waktuMembaca'];
          } else {
            waktuMembacaError = null;
          }

          if (responseBody['kategoriId'] != null) {
            kategoriIdError = responseBody['kategoriId'];
          } else {
            kategoriIdError = null;
          }

          if (responseBody['gambar'] != null) {
            gambarError = responseBody['gambar'];
          } else {
            gambarError = null;
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
          title: const Text('Hapus Berita'),
          content: const Text('Apa kamu yakin ingin menghapus berita ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/berita/${widget.id}"),
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
            content: const Text("Berita telah berhasil dihapuskan!"),
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
    isi = TextEditingController();
    deskripsi = TextEditingController();
    waktuMembaca = TextEditingController();
    kategoriId = TextEditingController();
    _isLoading = false;
    profile = null;
    opsiKategori = [
      {'value': '', 'label': ''}
    ];
    getKategori();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (mounted) {
        setState(() {
          profile = authProvider.profile!;
          token = authProvider.accessToken!;
        });
      }

      if (widget.id != null) getBerita();
    });
  }

  @override
  void dispose() {
    judul.dispose();
    isi.dispose();
    deskripsi.dispose();
    waktuMembaca.dispose();
    kategoriId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? 'Ubah' : 'Tambah'} Berita'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
        actions: [
          if (widget.id != null)
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
                      hapuskan();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(
                      value: 1,
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
                  'Silahkan isi formulir di bawah untuk me${widget.id != null ? 'ngubah' : 'nambahkan'} berita',
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    width: width - 30,
                    height: (width - 30) * 9 / 16,
                    decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: Stack(
                      children: [
                        if (gambarBerita != null)
                          Image.network(
                            gambarBerita!,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 75),
                            width: width - 30,
                            height: (width - 30) * 9 / 16,
                            fit: BoxFit.cover,
                          )
                        else if (croppedGambar != null)
                          Image.file(
                            File(croppedGambar!.path),
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 75),
                            width: width - 30,
                            height: (width - 30) * 9 / 16,
                            fit: BoxFit.cover,
                          )
                        else
                          const Center(child: Icon(Icons.error, size: 75)),
                        Positioned(
                          top: 0,
                          left: 0,
                          width: width - 30,
                          height: (width - 30) * 9 / 16,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            onTap: _getFromCamera,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          width: width - 30,
                          height: 35,
                          child: Container(
                            color: const Color(0x8C000000),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputComponent(controller: judul, errorText: judulError, label: 'Judul'),
                const SizedBox(height: 10),
                InputComponent(controller: deskripsi, errorText: deskripsiError, label: 'Deskripsi (Singkat)', maxLines: 3),
                const SizedBox(height: 10),
                InputComponent(controller: isi, errorText: isiError, label: 'Isi', maxLines: 8),
                const SizedBox(height: 10),
                InputComponent(controller: waktuMembaca, errorText: waktuMembacaError, label: 'Waktu Membaca'),
                const SizedBox(height: 10),
                SelectComponent(controller: kategoriId, errorText: kategoriIdError, label: 'Kategori', opsi: opsiKategori),
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
