// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class UbahProfilPage extends StatefulWidget {
  const UbahProfilPage({super.key});

  @override
  State<UbahProfilPage> createState() => _UbahProfilPageState();
}

class _UbahProfilPageState extends State<UbahProfilPage> {
  late final TextEditingController email;
  late final TextEditingController namaLengkap;
  late final TextEditingController nomorPonsel;
  late final TextEditingController jenisKelamin;
  String? namaLengkapError;
  String? nomorPonselError;
  String? jenisKelaminError;
  late bool _isLoading;
  XFile? fotoProfil;
  CroppedFile? croppedFotoProfil;

  void setData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final account = authProvider.getAccount();

      if (mounted) {
        setState(() {
          email.text = account['email'];
          namaLengkap.text = account['namaLengkap'];
          nomorPonsel.text = account['nomorPonsel'].toString();
          jenisKelamin.text = account['jenisKelamin'];
        });
      }
    });
  }

  void simpan() async {
    if (mounted) setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;
    final response = await http.put(
      Uri.parse("${dotenv.env['RESTFUL_API']}/account/change-profile"),
      body: {
        'namaLengkap': namaLengkap.text,
        'nomorPonsel': nomorPonsel.text,
        'jenisKelamin': jenisKelamin.text,
      },
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseCheck = await http.get(Uri.parse("${dotenv.env['RESTFUL_API']}/account/me"), headers: {'Authorization': 'Bearer $token'});
      final responseCheckBody = jsonDecode(responseCheck.body);

      if (responseCheckBody.containsKey('id')) {
        await authProvider.login(token ?? '', responseCheckBody);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Berhasil"),
            content: const Text("Informasi akun anda telah berhasil diubah!"),
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
      final responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          if (responseBody['namaLengkap'] != null) {
            namaLengkapError = responseBody['namaLengkap'];
          } else {
            namaLengkapError = null;
          }

          if (responseBody['nomorPonsel'] != null) {
            nomorPonselError = responseBody['nomorPonsel'];
          } else {
            nomorPonselError = null;
          }

          if (responseBody['jenisKelamin'] != null) {
            jenisKelaminError = responseBody['jenisKelamin'];
          } else {
            jenisKelaminError = null;
          }
        });
      }
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
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _ubahFotoProfil() async {
    if (croppedFotoProfil != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;
      var request = http.MultipartRequest('PUT', Uri.parse("${dotenv.env['RESTFUL_API']}/account/change-photo-profile"));
      request.headers.addAll({"Authorization": "Bearer $token"});
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedFotoProfil!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseCheck = await http.get(Uri.parse("${dotenv.env['RESTFUL_API']}/account/me"), headers: {'Authorization': 'Bearer $token'});
        final responseCheckBody = jsonDecode(responseCheck.body);

        if (responseCheckBody.containsKey('id')) {
          await authProvider.login(token ?? '', responseCheckBody);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Berhasil"),
              content: const Text("Foto profil berhasil diubah!"),
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

  Future<void> _cropImage() async {
    if (fotoProfil != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: fotoProfil!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 65,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Foto Profil',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Foto Profil'),
        ],
      );

      if (croppedFile != null) {
        if (mounted) setState(() => croppedFotoProfil = croppedFile);
        _ubahFotoProfil();
      }
    }
  }

  Future<void> _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (mounted) setState(() => fotoProfil = pickedFile);
    await _cropImage();
  }

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    namaLengkap = TextEditingController();
    nomorPonsel = TextEditingController();
    jenisKelamin = TextEditingController();
    _isLoading = false;
    setData();
  }

  @override
  void dispose() {
    email.dispose();
    namaLengkap.dispose();
    nomorPonsel.dispose();
    jenisKelamin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final List<String?> opsiJenisKelamin = ['', 'Laki-Laki', 'Perempuan'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Profil'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Stack(
                      children: [
                        Image.network(
                          '${dotenv.env['RESTFUL_API']}/account/foto-profil/${authProvider.getAccount()['gambar']}',
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 10),
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
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
                  const SizedBox(height: 22),
                  Text(
                    "${authProvider.getAccount()['namaLengkap']} ${authProvider.getAccount()['namaBelakang'] ?? ''}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    authProvider.getAccount()['email'],
                    style: const TextStyle(
                      color: Color(0xFF41405D),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  InputComponent(
                    label: 'Email Address',
                    controller: email,
                    readOnly: true,
                    disabled: true,
                  ),
                  const SizedBox(height: 10),
                  InputComponent(
                    label: 'Nama Lengkap',
                    controller: namaLengkap,
                    hintText: 'Ex: Doddy Suganda',
                    errorText: namaLengkapError,
                  ),
                  const SizedBox(height: 10),
                  SelectComponent(
                    label: 'Jenis Kelamin',
                    controller: jenisKelamin,
                    opsi: opsiJenisKelamin,
                    errorText: jenisKelaminError,
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nomor Ponsel',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              style: BorderStyle.solid,
                              color: const Color(0xFFF2F2F2),
                            ),
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFFBFBFB),
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          width: (MediaQuery.of(context).size.width - 65) * 0.19,
                          child: const Center(
                            child: Text(
                              '+62',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 65) * 0.8,
                          child: InputComponent(
                            hintText: 'Ex: 81234567890',
                            controller: nomorPonsel,
                            keyboardType: TextInputType.phone,
                            errorText: nomorPonselError,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ButtonComponent(label: 'Simpan', onClick: simpan),
                  const SizedBox(height: 20),
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
