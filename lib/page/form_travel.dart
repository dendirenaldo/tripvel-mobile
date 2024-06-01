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

class FormTravelPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;
  final bool? isDuplicate;

  const FormTravelPage({
    super.key,
    required this.refresh,
    this.id,
    this.isDuplicate,
  });

  @override
  State<FormTravelPage> createState() => _FormTravelPageState();
}

class _FormTravelPageState extends State<FormTravelPage> {
  late final TextEditingController nama;
  late final TextEditingController deskripsi;
  late final TextEditingController lokasi;
  String? gambarTravel;
  String? gambarError;
  String? namaError;
  String? deskripsiError;
  String? lokasiError;
  late List<dynamic> opsiTravel;
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
        gambarTravel = null;
      }
    }
  }

  Future<void> getTravel() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/travel/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          gambarTravel = '${dotenv.env['RESTFUL_API']}/travel/gambar/${responseBody['id']}';
          nama.text = responseBody['nama'];
          deskripsi.text = responseBody['deskripsi'];
          lokasi.text = responseBody['lokasi'];
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    var request = http.MultipartRequest(
        widget.id != null ? 'PUT' : 'PATCH', Uri.parse("${dotenv.env['RESTFUL_API']}/travel${widget.id != null ? '/${widget.id}' : ''}"));
    request.headers.addAll({"Authorization": "Bearer $token"});

    if (croppedGambar != null) {
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedGambar!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
    }

    request.fields['nama'] = nama.text;
    request.fields['deskripsi'] = deskripsi.text;
    request.fields['lokasi'] = lokasi.text;
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
            content: Text("Travel telah berhasil di${widget.id != null ? (widget.isDuplicate != true ? 'ubah' : 'duplikat') : 'tambahkan'}!"),
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

          if (responseBody['deskripsi'] != null) {
            deskripsiError = responseBody['deskripsi'];
          } else {
            deskripsiError = null;
          }

          if (responseBody['lokasi'] != null) {
            lokasiError = responseBody['lokasi'];
          } else {
            lokasiError = null;
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
          title: const Text('Hapus Travel'),
          content: const Text('Apa kamu yakin ingin menghapus travel ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/travel/${widget.id}"),
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
            content: const Text("Travel telah berhasil dihapuskan!"),
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
    deskripsi = TextEditingController();
    lokasi = TextEditingController();
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

      if (widget.id != null) getTravel();
    });
  }

  @override
  void dispose() {
    nama.dispose();
    deskripsi.dispose();
    lokasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? (widget.isDuplicate != true ? 'Ubah' : 'Duplikat') : 'Tambah'} Travel'),
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
                          builder: (context) => FormTravelPage(
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
                  'Silahkan isi formulir di bawah untuk me${widget.id != null && widget.isDuplicate != true ? 'ngubah' : 'nambahkan'} travel',
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipOval(
                    child: Stack(
                      children: [
                        if (gambarTravel != null)
                          Image.network(
                            gambarTravel!,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 75),
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                        else if (croppedGambar != null)
                          Image.file(
                            File(croppedGambar!.path),
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 75),
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                        else
                          const Icon(Icons.error, size: 75),
                        Positioned(
                          top: 0,
                          left: 0,
                          width: 75,
                          height: 75,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            onTap: _getFromCamera,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          width: 75,
                          height: 25,
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
                InputComponent(controller: nama, errorText: namaError, label: 'Nama'),
                const SizedBox(height: 10),
                InputComponent(controller: deskripsi, errorText: deskripsiError, label: 'Deskripsi', maxLines: 10),
                const SizedBox(height: 10),
                InputComponent(controller: lokasi, errorText: lokasiError, label: 'Lokasi', maxLines: 3),
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
