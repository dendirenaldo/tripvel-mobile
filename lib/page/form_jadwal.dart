// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';
import 'package:tripvel/screen/enam_penumpang.dart';
import 'package:tripvel/screen/lima_penumpang.dart';
import 'package:tripvel/screen/tujuh_penumpang.dart';

class FormJadwalPage extends StatefulWidget {
  final void Function() refresh;
  final int? id;
  final bool? isDuplicate;

  const FormJadwalPage({
    super.key,
    required this.refresh,
    this.id,
    this.isDuplicate,
  });

  @override
  State<FormJadwalPage> createState() => _FormJadwalPageState();
}

class _FormJadwalPageState extends State<FormJadwalPage> {
  late final PemesananProvider pemesananProvider;
  late final TextEditingController travelId;
  late final TextEditingController mobilId;
  late final TextEditingController supirId;
  late final TextEditingController asalId;
  late final TextEditingController tujuanId;
  late final TextEditingController tanggal;
  late final TextEditingController jamBerangkat;
  late final TextEditingController jamTiba;
  late final TextEditingController harga;
  late final TextEditingController tipe;
  String? travelIdError;
  String? mobilIdError;
  String? supirIdError;
  String? asalIdError;
  String? tujuanIdError;
  String? tanggalError;
  String? jamBerangkatError;
  String? jamTibaError;
  String? hargaError;
  String? tipeError;
  late List<dynamic> opsiTravel;
  late List<dynamic> opsiMobil;
  late List<dynamic> opsiSupir;
  late List<dynamic> opsiTujuan;
  late final List<String> opsiTipe;
  late int kapasitasPenumpang;
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
    if (mounted) {
      setState(() {
        opsiMobil = [
          {'value': '', 'label': ''}
        ];
      });
    }

    if (travelId.text != '') {
      final response = await http.get(
        Uri.parse('${dotenv.env['RESTFUL_API']}/mobil?travelId=${travelId.text}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['data'].isNotEmpty) {
          final List<dynamic> tempMobil = [];

          for (var data in responseBody['data']) {
            tempMobil.add({
              'value': data['id'].toString(),
              'label': '${data['merek']} ${data['model']} (${data['platNomor']})',
            });
          }

          if (mounted) setState(() => opsiMobil.addAll(tempMobil));
        }
      }
    }
  }

  Future<void> getInfoMobil() async {
    if (mounted) setState(() => kapasitasPenumpang = 0);

    if (travelId.text != '') {
      final response = await http.get(
        Uri.parse('${dotenv.env['RESTFUL_API']}/mobil/${mobilId.text}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        if (responseBody['id'] != null && mounted) setState(() => kapasitasPenumpang = responseBody['jumlahPenumpang']);
      }
    }
  }

  Future<void> getSupir() async {
    if (mounted) {
      setState(() {
        opsiSupir = [
          {'value': '', 'label': ''}
        ];
      });
    }

    if (travelId.text != '') {
      final response = await http.get(
        Uri.parse('${dotenv.env['RESTFUL_API']}/account?filterRole=Supir'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['data'].isNotEmpty) {
          final List<dynamic> tempSupir = [];

          for (var data in responseBody['data']) {
            tempSupir.add({
              'value': data['id'].toString(),
              'label': '${data['namaLengkap']}',
            });
          }

          if (mounted) setState(() => opsiSupir.addAll(tempSupir));
        }
      }
    }
  }

  Future<void> getTujuan() async {
    if (mounted) {
      setState(() {
        opsiTujuan = [
          {'value': '', 'label': ''}
        ];
      });
    }

    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/tujuan?offset=0&limit=15&order={"index":"createdAt","order":"desc"}'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<dynamic> tempTujuan = [];

        for (var data in responseBody['data']) {
          tempTujuan.add({
            'value': data['id'].toString(),
            'label': data['namaLengkap'],
          });
        }

        if (mounted) setState(() => opsiTujuan.addAll(tempTujuan));
      }
    }
  }

  void getJam(String variable) async {
    TimeOfDay? pickedDate = await showTimePicker(
      context: context,
      initialTime: variable == 'tiba'
          ? (jamTiba.text == ''
              ? TimeOfDay.now()
              : TimeOfDay(hour: int.parse(jamTiba.text.split(':')[0]), minute: int.parse(jamTiba.text.split(':')[1])))
          : (jamBerangkat.text == ''
              ? TimeOfDay.now()
              : TimeOfDay(hour: int.parse(jamBerangkat.text.split(':')[0]), minute: int.parse(jamBerangkat.text.split(':')[1]))),
    );

    if (pickedDate != null) {
      String formattedDate = pickedDate.format(context);

      if (mounted) {
        setState(() {
          if (variable == 'berangkat') {
            jamBerangkat.text = formattedDate;
          } else if (variable == 'tiba') {
            jamTiba.text = formattedDate;
          }
        });
      }
    }
  }

  void getTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: tanggal.text != '' ? DateTime.parse(tanggal.text) : DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 1),
      currentDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (mounted) setState(() => tanggal.text = formattedDate);
    }
  }

  Future<void> getJadwal() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/jadwal/${widget.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          travelId.text = responseBody['travelId'].toString();
          Future.wait([getMobil()]).then((_) {
            if (opsiMobil.any((item) => item['value'] == responseBody['mobilId'].toString())) {
              mobilId.text = responseBody['mobilId'].toString();
            } else {
              mobilId.text = '';
            }
          });
          Future.wait([getSupir()]).then((_) {
            if (opsiSupir.any((item) => item['value'] == responseBody['supirId'].toString())) {
              supirId.text = responseBody['supirId'].toString();
            } else {
              supirId.text = '';
            }
          });

          if (opsiTujuan.any((item) => item['value'] == responseBody['asalId'].toString())) {
            asalId.text = responseBody['asalId'].toString();
          }

          if (opsiTujuan.any((item) => item['value'] == responseBody['tujuanId'].toString())) {
            tujuanId.text = responseBody['tujuanId'].toString();
          }

          if (widget.isDuplicate != true) tanggal.text = responseBody['tanggal'];
          jamBerangkat.text = responseBody['jamBerangkat'].substring(0, 5);
          jamTiba.text = responseBody['jamTiba'].substring(0, 5);
          harga.text = responseBody['harga'].toString();
          tipe.text = responseBody['tipe'];
          kapasitasPenumpang = responseBody['mobil']['jumlahPenumpang'];
        });

        if (responseBody['kursiTerisi'].isNotEmpty) {
          pemesananProvider.listKursi = responseBody['kursiTerisi'].map((val) => val['nomorKursi']).toList();
        }
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> simpan() async {
    if (mounted) setState(() => _isLoading = true);
    late final http.Response response;
    final Object body = jsonEncode({
      'travelId': travelId.text == '' ? null : travelId.text,
      'mobilId': mobilId.text == '' ? null : mobilId.text,
      'supirId': supirId.text == '' ? null : supirId.text,
      'asalId': asalId.text == '' ? null : asalId.text,
      'tujuanId': tujuanId.text == '' ? null : tujuanId.text,
      'tanggal': tanggal.text,
      'jamBerangkat': jamBerangkat.text,
      'jamTiba': jamTiba.text,
      'harga': harga.text == '' || harga.text == '0' ? null : harga.text,
      'tipe': tipe.text,
      'kursiTerisi': pemesananProvider.listKursi
    });

    if (widget.id != null && widget.isDuplicate != true) {
      response = await http.put(
        Uri.parse('${dotenv.env['RESTFUL_API']}/jadwal/${widget.id}'),
        body: body,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
    } else {
      response = await http.patch(
        Uri.parse('${dotenv.env['RESTFUL_API']}/jadwal'),
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
            content: Text("Jadwal telah berhasil di${widget.id != null ? (widget.isDuplicate != true ? 'ubah' : 'duplikat') : 'tambahkan'}!"),
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

          if (responseBody['mobilId'] != null) {
            mobilIdError = responseBody['mobilId'];
          } else {
            mobilIdError = null;
          }

          if (responseBody['supirId'] != null) {
            supirIdError = responseBody['supirId'];
          } else {
            supirIdError = null;
          }

          if (responseBody['asalId'] != null) {
            asalIdError = responseBody['asalId'];
          } else {
            asalIdError = null;
          }

          if (responseBody['tujuanId'] != null) {
            tujuanIdError = responseBody['tujuanId'];
          } else {
            tujuanIdError = null;
          }

          if (responseBody['tanggal'] != null) {
            tanggalError = responseBody['tanggal'];
          } else {
            tanggalError = null;
          }

          if (responseBody['jamBerangkat'] != null) {
            jamBerangkatError = responseBody['jamBerangkat'];
          } else {
            jamBerangkatError = null;
          }

          if (responseBody['jamTiba'] != null) {
            jamTibaError = responseBody['jamTiba'];
          } else {
            jamTibaError = null;
          }

          if (responseBody['harga'] != null) {
            hargaError = responseBody['harga'];
          } else {
            hargaError = null;
          }

          if (responseBody['tipe'] != null) {
            tipeError = responseBody['tipe'];
          } else {
            tipeError = null;
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
          title: const Text('Hapus Jadwal'),
          content: const Text('Apa kamu yakin ingin menghapus jadwal ini?'),
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
      Uri.parse("${dotenv.env['RESTFUL_API']}/jadwal/${widget.id}"),
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
            content: const Text("Jadwal telah berhasil dihapuskan!"),
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
    mobilId = TextEditingController();
    supirId = TextEditingController();
    asalId = TextEditingController();
    tujuanId = TextEditingController();
    tanggal = TextEditingController();
    jamBerangkat = TextEditingController();
    jamTiba = TextEditingController();
    harga = TextEditingController();
    tipe = TextEditingController();
    opsiTravel = [
      {'value': '', 'label': ''}
    ];
    opsiMobil = [
      {'value': '', 'label': ''}
    ];
    opsiSupir = [
      {'value': '', 'label': ''}
    ];
    opsiTujuan = [
      {'value': '', 'label': ''}
    ];
    opsiTipe = ['', 'Ekonomi', 'Eksekutif'];
    kapasitasPenumpang = 0;
    _isLoading = false;
    profile = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      pemesananProvider = Provider.of<PemesananProvider>(context, listen: false);
      pemesananProvider.listKursi = [];
      if (mounted) {
        setState(() {
          profile = authProvider.profile!;
          token = authProvider.accessToken!;
        });
      }

      if (widget.id != null) {
        Future.wait([getTravel(), getTujuan()]).then((_) => getJadwal());
      } else {
        if (profile['role'] == 'Travel') {
          Future.wait([getTravel()]).then((_) {
            if (opsiTravel.any((item) => item['value'] == profile['travelId'].toString())) {
              travelId.text = profile['travelId'].toString();
              getTujuan();
              getMobil();
              getSupir();
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
    mobilId.dispose();
    supirId.dispose();
    asalId.dispose();
    tujuanId.dispose();
    tanggal.dispose();
    jamBerangkat.dispose();
    jamTiba.dispose();
    harga.dispose();
    tipe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id != null ? (widget.isDuplicate != true ? 'Ubah' : 'Duplikat') : 'Tambah'} Jadwal'),
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
                          builder: (context) => FormJadwalPage(
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
                    'Silahkan isi formulir di bawah untuk me${widget.id != null && widget.isDuplicate != true ? 'ngubah' : 'nambahkan'} jadwal travel',
                    style: const TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  SelectComponent(
                    controller: travelId,
                    errorText: travelIdError,
                    label: 'Travel',
                    opsi: opsiTravel,
                    readOnly: profile != null && profile['role']! == 'Admin' ? false : true,
                    listen: () {
                      getMobil();
                      getSupir();
                    },
                  ),
                  const SizedBox(height: 10),
                  SelectComponent(controller: mobilId, errorText: mobilIdError, label: 'Mobil', opsi: opsiMobil, listen: getInfoMobil),
                  const SizedBox(height: 10),
                  SelectComponent(controller: supirId, errorText: supirIdError, label: 'Supir', opsi: opsiSupir),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: ((width - 30) * 0.5) - 5,
                        child: SelectComponent(controller: asalId, errorText: asalIdError, label: 'Asal', opsi: opsiTujuan),
                      ),
                      SizedBox(
                        width: ((width - 30) * 0.5) - 5,
                        child: SelectComponent(controller: tujuanId, errorText: tujuanIdError, label: 'Tujuan', opsi: opsiTujuan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InputComponent(controller: tanggal, errorText: tanggalError, label: 'Tanggal', onTap: getTanggal, prefixIcon: Icons.calendar_month),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: ((width - 30) * 0.5) - 5,
                        child: InputComponent(
                            controller: jamBerangkat,
                            errorText: jamBerangkatError,
                            label: 'Jam Berangkat',
                            onTap: () => getJam('berangkat'),
                            prefixIcon: Icons.timelapse_rounded),
                      ),
                      SizedBox(
                        width: ((width - 30) * 0.5) - 5,
                        child: InputComponent(
                            controller: jamTiba,
                            errorText: jamTibaError,
                            label: 'Jam Tiba',
                            onTap: () => getJam('tiba'),
                            prefixIcon: Icons.timelapse_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: ((width - 30) * 0.5) - 5,
                        child: InputComponent(controller: harga, errorText: hargaError, label: 'Harga', keyboardType: TextInputType.number),
                      ),
                      SizedBox(
                        width: ((width - 30) * 0.5) - 5,
                        child: SelectComponent(controller: tipe, errorText: tipeError, label: 'Tipe', opsi: opsiTipe),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (kapasitasPenumpang != 0)
                    const Text(
                      'Kursi Terisi',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13),
                      textScaleFactor: 1.0,
                    ),
                  const SizedBox(height: 10),
                  if (kapasitasPenumpang == 7)
                    TujuhPenumpangScreen(jumlahPenumpang: 100, listTerisi: [], width: width)
                  else if (kapasitasPenumpang == 6)
                    const EnamPenumpangScreen(jumlahPenumpang: 100, listTerisi: [])
                  else if (kapasitasPenumpang == 5)
                    LimaPenumpangScreen(jumlahPenumpang: 100, listTerisi: [], width: width),
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
        ],
      ),
    );
  }
}
