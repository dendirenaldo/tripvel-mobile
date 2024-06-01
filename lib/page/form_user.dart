// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:tripvel/provider/auth_provider.dart';

class FormUserPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;

  const FormUserPage({
    super.key,
    required this.refresh,
    this.id,
  });

  @override
  State<FormUserPage> createState() => _FormUserPageState();
}

class _FormUserPageState extends State<FormUserPage> {
  late final TextEditingController namaLengkap;
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController jenisKelamin;
  late final TextEditingController nomorPonsel;
  late final TextEditingController role;
  late final TextEditingController travelId;
  late final TextEditingController isActive;
  String? gambarUser;
  String? gambarError;
  String? namaLengkapError;
  String? emailError;
  String? passwordError;
  String? jenisKelaminError;
  String? nomorPonselError;
  String? roleError;
  String? travelIdError;
  String? isActiveError;
  late List<String> opsiRole;
  late List<String> opsiJenisKelamin;
  late List<dynamic> opsiTravel;
  late List<dynamic> opsiIsActive;
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
        gambarUser = null;
      }
    }
  }

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

        if (mounted) {
          setState(() {
            opsiTravel.addAll(tempTravel);
            if (profile['role'] == 'Travel' && opsiTravel.any((item) => item['value'] == profile['travelId'].toString())) {
              travelId.text = profile['travelId'].toString();
            }
          });
        }
      }
    }
  }

  Future<void> getUser() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/account/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          gambarUser = '${dotenv.env['RESTFUL_API']}/account/foto-profil/${responseBody['gambar']}';
          namaLengkap.text = responseBody['namaLengkap'];
          email.text = responseBody['email'];
          jenisKelamin.text = responseBody['jenisKelamin'];
          nomorPonsel.text = responseBody['nomorPonsel'] != null ? '0${responseBody['nomorPonsel'].toString()}' : '';
          role.text = responseBody['role'];
          isActive.text = responseBody['isActive'] == true ? 'true' : 'false';

          if (responseBody['role'] == 'Travel' || responseBody['role'] == 'Supir') {
            Future.wait([getTravel()]).then((_) => travelId.text =
                opsiTravel.any((item) => item['value'] == responseBody['travelId'].toString()) ? responseBody['travelId'].toString() : '');
          }
        });
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> hapuskan() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus User'),
          content: const Text('Apa kamu yakin ingin menghapus user ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/account/${widget.id}"),
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
            content: const Text("User telah berhasil dihapuskan!"),
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

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    var request = http.MultipartRequest(
        widget.id != null ? 'PUT' : 'PATCH', Uri.parse("${dotenv.env['RESTFUL_API']}/account${widget.id != null ? '/${widget.id}' : ''}"));
    request.headers.addAll({"Authorization": "Bearer $token"});

    if (croppedGambar != null) {
      final httpImage =
          await http.MultipartFile.fromPath('gambar', croppedGambar!.path, contentType: MediaType('image', 'jpeg'), filename: 'myImage.jpg');
      request.files.add(httpImage);
    }

    request.fields['namaLengkap'] = namaLengkap.text;
    request.fields['email'] = email.text;
    if (password.text != '') request.fields['password'] = password.text;
    request.fields['jenisKelamin'] = jenisKelamin.text;
    if (nomorPonsel.text != '' && nomorPonsel.text != '0') request.fields['nomorPonsel'] = nomorPonsel.text;
    request.fields['role'] = role.text;
    if (travelId.text != '') request.fields['travelId'] = travelId.text;
    if (isActive.text != '') request.fields['isActive'] = isActive.text;
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
            content: Text("User telah berhasil di${widget.id != null ? 'ubah' : 'tambahkan'}!"),
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

          if (responseBody['email'] != null) {
            emailError = responseBody['email'];
          } else {
            emailError = null;
          }

          if (responseBody['password'] != null) {
            passwordError = responseBody['password'];
          } else {
            passwordError = null;
          }

          if (responseBody['jenisKelamin'] != null) {
            jenisKelaminError = responseBody['jenisKelamin'];
          } else {
            jenisKelaminError = null;
          }

          if (responseBody['nomorPonsel'] != null) {
            nomorPonselError = responseBody['nomorPonsel'];
          } else {
            nomorPonselError = null;
          }

          if (responseBody['role'] != null) {
            roleError = responseBody['role'];
          } else {
            roleError = null;
          }

          if (responseBody['travelId'] != null) {
            travelIdError = responseBody['travelId'];
          } else {
            travelIdError = null;
          }

          if (responseBody['isActive'] != null) {
            isActiveError = responseBody['isActive'];
          } else {
            isActiveError = null;
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

  @override
  void initState() {
    super.initState();
    namaLengkap = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    jenisKelamin = TextEditingController();
    nomorPonsel = TextEditingController();
    role = TextEditingController();
    travelId = TextEditingController();
    isActive = TextEditingController();
    opsiRole = [''];
    opsiJenisKelamin = ['', 'Laki-Laki', 'Perempuan'];
    opsiTravel = [
      {'value': '', 'label': ''}
    ];
    opsiIsActive = [
      {'value': '', 'label': ''},
      {'value': 'true', 'label': 'Aktif'},
      {'value': 'false', 'label': 'Tidak Aktif'}
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

      if (profile['role'] == 'Admin') opsiRole.add('Admin');
      opsiRole.addAll(['Travel', 'Supir']);
      if (profile['role'] == 'Admin') opsiRole.add('Pelanggan');
      if (widget.id != null) {
        getUser();
      }
    });
  }

  @override
  void dispose() {
    namaLengkap.dispose();
    email.dispose();
    password.dispose();
    jenisKelamin.dispose();
    nomorPonsel.dispose();
    role.dispose();
    travelId.dispose();
    isActive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? 'Ubah' : 'Tambah'} User'),
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
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Silahkan isi formulir di bawah untuk me${widget.id != null ? 'ngubah' : 'nambahkan'} user',
                    style: const TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ClipOval(
                      child: Stack(
                        children: [
                          if (gambarUser != null)
                            Image.network(
                              gambarUser!,
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
                  InputComponent(controller: namaLengkap, errorText: namaLengkapError, label: 'Nama Lengkap'),
                  const SizedBox(height: 10),
                  InputComponent(controller: email, errorText: emailError, label: 'Email Address'),
                  const SizedBox(height: 10),
                  InputComponent(controller: password, errorText: passwordError, label: 'Kata Sandi', obscureText: true),
                  const SizedBox(height: 10),
                  SelectComponent(controller: jenisKelamin, errorText: jenisKelaminError, label: 'Jenis Kelamin', opsi: opsiJenisKelamin),
                  const SizedBox(height: 10),
                  InputComponent(controller: nomorPonsel, errorText: nomorPonselError, label: 'Nomor Ponsel'),
                  const SizedBox(height: 10),
                  SelectComponent(
                      controller: role,
                      errorText: roleError,
                      label: 'Hak Akses',
                      opsi: opsiRole,
                      listen: () {
                        if (mounted) setState(() => role.text = role.text);
                        travelId.text = '';
                        if (role.text == 'Travel' || role.text == 'Supir') getTravel();
                      }),
                  if (role.text == 'Travel' || role.text == 'Supir') const SizedBox(height: 10),
                  if (role.text == 'Travel' || role.text == 'Supir')
                    SelectComponent(
                      controller: travelId,
                      errorText: travelIdError,
                      label: 'Travel',
                      opsi: opsiTravel,
                      readOnly: profile['role'] == 'Travel' ? true : false,
                    ),
                  const SizedBox(height: 10),
                  SelectComponent(controller: isActive, errorText: isActiveError, label: 'Aktif?', opsi: opsiIsActive),
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
        ],
      ),
    );
  }
}
