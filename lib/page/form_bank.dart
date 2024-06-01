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

class FormBankPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;

  const FormBankPage({
    super.key,
    required this.refresh,
    this.id,
  });

  @override
  State<FormBankPage> createState() => _FormBankPageState();
}

class _FormBankPageState extends State<FormBankPage> {
  late final TextEditingController namaBank;
  late final TextEditingController nomorRekening;
  late final TextEditingController namaPemilik;
  late final TextEditingController instruksi;
  String? gambarBank;
  String? gambarError;
  String? namaBankError;
  String? nomorRekeningError;
  String? namaPemilikError;
  String? instruksiError;
  late List<dynamic> opsiBank;
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
        gambarBank = null;
      }
    }
  }

  Future<void> getBank() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/bank-account/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          gambarBank = '${dotenv.env['RESTFUL_API']}/bank-account/gambar/${responseBody['id']}';
          namaBank.text = responseBody['namaBank'];
          nomorRekening.text = responseBody['nomorRekening'].toString();
          namaPemilik.text = responseBody['namaPemilik'];
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    var request = http.MultipartRequest(
        widget.id != null ? 'PUT' : 'PATCH', Uri.parse("${dotenv.env['RESTFUL_API']}/bank-account${widget.id != null ? '/${widget.id}' : ''}"));
    request.headers.addAll({"Authorization": "Bearer $token"});

    if (croppedGambar != null) {
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedGambar!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
    }

    request.fields['namaBank'] = namaBank.text;
    if (nomorRekening.text != '') request.fields['nomorRekening'] = nomorRekening.text;
    request.fields['namaPemilik'] = namaPemilik.text;
    request.fields['instruksi'] = instruksi.text;
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
            content: Text("Bank telah berhasil di${widget.id != null ? 'ubah' : 'tambahkan'}!"),
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
          if (responseBody['namaBank'] != null) {
            namaBankError = responseBody['namaBank'];
          } else {
            namaBankError = null;
          }

          if (responseBody['nomorRekening'] != null) {
            nomorRekeningError = responseBody['nomorRekening'];
          } else {
            nomorRekeningError = null;
          }

          if (responseBody['namaPemilik'] != null) {
            namaPemilikError = responseBody['namaPemilik'];
          } else {
            namaPemilikError = null;
          }

          if (responseBody['instruksi'] != null) {
            instruksiError = responseBody['instruksi'];
          } else {
            instruksiError = null;
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
          title: const Text('Hapus Bank'),
          content: const Text('Apa kamu yakin ingin menghapus bank ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/bank-account/${widget.id}"),
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
            content: const Text("Bank telah berhasil dihapuskan!"),
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
    namaBank = TextEditingController();
    nomorRekening = TextEditingController();
    namaPemilik = TextEditingController();
    instruksi = TextEditingController();
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

      if (widget.id != null) getBank();
    });
  }

  @override
  void dispose() {
    namaBank.dispose();
    nomorRekening.dispose();
    namaPemilik.dispose();
    instruksi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? 'Ubah' : 'Tambah'} Bank'),
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
                  'Silahkan isi formulir di bawah untuk me${widget.id != null ? 'ngubah' : 'nambahkan'} bank',
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipOval(
                    child: Stack(
                      children: [
                        if (gambarBank != null)
                          Image.network(
                            gambarBank!,
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
                InputComponent(controller: namaBank, errorText: namaBankError, label: 'Bank'),
                const SizedBox(height: 10),
                InputComponent(controller: nomorRekening, errorText: nomorRekeningError, label: 'Nomor Rekening', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                InputComponent(controller: namaPemilik, errorText: namaPemilikError, label: 'Pemilik'),
                const SizedBox(height: 10),
                InputComponent(controller: instruksi, errorText: instruksiError, label: 'Instruksi', maxLines: 12),
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
