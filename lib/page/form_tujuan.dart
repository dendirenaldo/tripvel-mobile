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
import 'package:tripvel/provider/auth_provider.dart';

class FormTujuanPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;

  const FormTujuanPage({
    super.key,
    required this.refresh,
    this.id,
  });

  @override
  State<FormTujuanPage> createState() => _FormTujuanPageState();
}

class _FormTujuanPageState extends State<FormTujuanPage> {
  late final TextEditingController namaLengkap;
  late final TextEditingController namaSingkatan;
  late final TextEditingController deskripsi;
  late final TextEditingController longitude;
  late final TextEditingController latitude;
  String? gambarTujuan;
  String? gambarError;
  String? namaLengkapError;
  String? namaSingkatanError;
  String? deskripsiError;
  String? longitudeError;
  String? latitudeError;
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
        gambarTujuan = null;
      }
    }
  }

  Future<void> getTujuan() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/tujuan/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          gambarTujuan = '${dotenv.env['RESTFUL_API']}/tujuan/gambar/${responseBody['id']}';
          namaLengkap.text = responseBody['namaLengkap'];
          namaSingkatan.text = responseBody['namaSingkatan'];
          deskripsi.text = responseBody['deskripsi'];
          longitude.text = responseBody['longitude'].toString();
          latitude.text = responseBody['latitude'].toString();
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    var request = http.MultipartRequest(
        widget.id != null ? 'PUT' : 'PATCH', Uri.parse("${dotenv.env['RESTFUL_API']}/tujuan${widget.id != null ? '/${widget.id}' : ''}"));
    request.headers.addAll({"Authorization": "Bearer $token"});

    if (croppedGambar != null) {
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedGambar!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
    }

    request.fields['namaLengkap'] = namaLengkap.text;
    request.fields['namaSingkatan'] = namaSingkatan.text;
    request.fields['deskripsi'] = deskripsi.text;
    request.fields['longitude'] = longitude.text;
    request.fields['latitude'] = latitude.text;
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
            content: Text("Tujuan telah berhasil di${widget.id != null ? 'ubah' : 'tambahkan'}!"),
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
          if (responseBody['namaLengkap'] != null) {
            namaLengkapError = responseBody['namaLengkap'];
          } else {
            namaLengkapError = null;
          }

          if (responseBody['namaSingkatan'] != null) {
            namaSingkatanError = responseBody['namaSingkatan'];
          } else {
            namaSingkatanError = null;
          }

          if (responseBody['deskripsi'] != null) {
            deskripsiError = responseBody['deskripsi'];
          } else {
            deskripsiError = null;
          }

          if (responseBody['longitude'] != null) {
            longitudeError = responseBody['longitude'];
          } else {
            longitudeError = null;
          }

          if (responseBody['latitude'] != null) {
            latitudeError = responseBody['latitude'];
          } else {
            latitudeError = null;
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
          title: const Text('Hapus Tujuan'),
          content: const Text('Apa kamu yakin ingin menghapus tujuan ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/tujuan/${widget.id}"),
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
            content: const Text("Tujuan telah berhasil dihapuskan!"),
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
    namaLengkap = TextEditingController();
    namaSingkatan = TextEditingController();
    deskripsi = TextEditingController();
    longitude = TextEditingController();
    latitude = TextEditingController();
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

      if (widget.id != null) getTujuan();
    });
  }

  @override
  void dispose() {
    namaLengkap.dispose();
    namaSingkatan.dispose();
    deskripsi.dispose();
    longitude.dispose();
    latitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? 'Ubah' : 'Tambah'} Tujuan'),
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
                  'Silahkan isi formulir di bawah untuk me${widget.id != null ? 'ngubah' : 'nambahkan'} tujuan',
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
                        if (gambarTujuan != null)
                          Image.network(
                            gambarTujuan!,
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
                InputComponent(controller: namaLengkap, errorText: namaLengkapError, label: 'Nama Lengkap'),
                const SizedBox(height: 10),
                InputComponent(controller: namaSingkatan, errorText: namaSingkatanError, label: 'Nama Singkatan'),
                const SizedBox(height: 10),
                InputComponent(controller: deskripsi, errorText: deskripsiError, label: 'Deskripsi', maxLines: 8),
                const SizedBox(height: 10),
                InputComponent(controller: longitude, errorText: longitudeError, label: 'Longitude'),
                const SizedBox(height: 10),
                InputComponent(controller: latitude, errorText: latitudeError, label: 'Latitude'),
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
