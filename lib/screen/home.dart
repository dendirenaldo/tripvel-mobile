import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/card/berita_card.dart';
import 'package:tripvel/card/tujuan_card.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/home_menu_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:intl/intl.dart';
import 'package:tripvel/component/select_component.dart';
import 'package:tripvel/page/cari.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/page/daftar_berita.dart';
import 'package:tripvel/page/daftar_tujuan.dart';
import 'package:tripvel/page/login.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';
import 'package:tripvel/screen/bank.dart';
import 'package:tripvel/screen/berita.dart';
import 'package:tripvel/screen/jadwal.dart';
import 'package:tripvel/screen/kategori.dart';
import 'package:tripvel/screen/mobil.dart';
import 'package:tripvel/screen/promo.dart';
import 'package:tripvel/screen/travel.dart';
import 'package:tripvel/screen/tujuan.dart';
import 'package:tripvel/screen/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  late final TextEditingController fromId;
  late final TextEditingController from;
  late final TextEditingController destinationId;
  late final TextEditingController destination;
  late final TextEditingController tanggal;
  late final TextEditingController tipe;
  late final TextEditingController jumlahPenumpang;
  late final List<String> opsiTipe;
  late List<dynamic> listTujuan;
  late List<Widget> berita;
  String? fromError;
  String? destinationError;
  String? tanggalError;
  String? jumlahPenumpangError;
  String? tipeError;
  late dynamic token;
  late dynamic profile;

  void carikan() {
    if (profile != null) {
      if (profile['role']! == 'Pelanggan') {
        int count = 0;
        setState(() {
          if (from.text == '') {
            fromError = 'Pilih asal keberangkatan';
          } else {
            count++;
            fromError = null;
          }

          if (destination.text == '') {
            destinationError = 'Pilih tujuan kepergian';
          } else if (destination.text == from.text) {
            destinationError = 'Jangan pilih tujuan yang sama dengan asal keberangkatan';
          } else {
            count++;
            destinationError = null;
          }

          if (tanggal.text == '') {
            tanggalError = 'Pilih tanggal berangkat';
          } else {
            count++;
            tanggalError = null;
          }

          if (jumlahPenumpang.text == '') {
            jumlahPenumpangError = 'Masukkan jumlah penumpang';
          } else {
            count++;
            jumlahPenumpangError = null;
          }

          if (tipe.text == '') {
            tipeError = 'Pilih tipe jadwal';
          } else {
            count++;
            tipeError = null;
          }
        });

        if (count == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CariPage(
                from: from.text,
                fromId: fromId.text,
                destination: destination.text,
                destinationId: destinationId.text,
                tanggal: tanggal.text,
                jumlahPenumpang: jumlahPenumpang.text,
                tipe: tipe.text,
              ),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Gagal'),
              content: const Text('Hanya pelanggan yang dapat mencari jadwal keberangkatan'),
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

  void destinasi(TextEditingController asalController, TextEditingController tujuanController, TextEditingController asalControllerId,
      TextEditingController tujuanControllerId, double width, double height, String tipe) {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: false);
    final listTujuanFiltered = (tipe == 'Asal'
        ? listTujuan.where((item) => item['namaLengkap'] != destination.text).toList()
        : listTujuan.where((item) => item['namaLengkap'] != from.text).toList());
    final TextEditingController sumber = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.only(top: 35, bottom: 25, left: 20, right: 20),
                width: double.infinity,
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text('Pilih $tipe', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    InputComponent(controller: sumber, hintText: 'Cari kota atau kabupaten'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Pencarian Terbaik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        // TextButton(onPressed: () {}, child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...listTujuanFiltered.map(
                      (val) => Material(
                        child: InkWell(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                if (tipe == 'Tujuan') {
                                  tujuanController.text = val['namaLengkap'];
                                  tujuanControllerId.text = val['id'].toString();
                                } else if (tipe == 'Asal') {
                                  asalController.text = val['namaLengkap'];
                                  asalControllerId.text = val['id'].toString();
                                }
                              });
                              // pemesananProvider.set(tipe, val['id']);
                            }
                            Navigator.of(context).pop();
                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Icon(IconlyLight.home, size: 33),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(val['namaLengkap'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 5),
                                        const Text('Riau, Indonesia', style: TextStyle(fontSize: 15, color: Colors.black45)),
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xB32459A9),
                                  ),
                                  child: Text(val['namaSingkatan'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 13,
                width: width * 0.2,
                child: Container(
                  width: width * 0.2,
                  clipBehavior: Clip.hardEdge,
                  height: 6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: const Divider(thickness: 6),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> getTujuan() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/tujuan/favorit'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          listTujuan = responseBody['data'];
        });
      }
    }
  }

  Future<void> getBerita() async {
    if (mounted) setState(() => berita = []);

    final response = await http.get(
      Uri.parse('${dotenv.env['RESTFUL_API']}/berita?offset=0&limit=5&order={"index":"createdAt","order":"desc"}'),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<Widget> tempBerita = [];

        for (var e in responseBody['data']) {
          tempBerita.add(BeritaCard(
            id: e['id'],
            title: e['judul'],
            deskripsi: e['deskripsi'],
            thumbnail: "${dotenv.env['RESTFUL_API']}/berita/gambar/${e['id']}",
            authorName: "${e['auth']['namaLengkap']}",
            authorImage: "${dotenv.env['RESTFUL_API']}/auth/gambar/${e['auth']['id']}",
          ));
        }

        if (mounted) setState(() => berita = tempBerita);
      }
    }
  }

  void getTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: tanggal.text != '' ? DateTime.parse(tanggal.text) : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      currentDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (mounted) setState(() => tanggal.text = formattedDate);
    }
  }

  @override
  void initState() {
    super.initState();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateTime currentDate = DateTime.now();
    from = TextEditingController();
    destination = TextEditingController();
    fromId = TextEditingController();
    destinationId = TextEditingController();
    tanggal = TextEditingController();
    jumlahPenumpang = TextEditingController();
    tipe = TextEditingController();
    tanggal.text = dateFormat.format(currentDate);
    opsiTipe = ['', 'Ekonomi', 'Eksekutif'];
    tipe.text = 'Ekonomi';
    jumlahPenumpang.text = '1';
    listTujuan = [];
    token = '';
    profile = {};
    getTujuan();
    getBerita();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (mounted) {
        setState(() {
          token = authProvider.accessToken;
          profile = authProvider.getAccount();
        });
      }
    });
  }

  @override
  void dispose() {
    from.dispose();
    destination.dispose();
    fromId.dispose();
    destinationId.dispose();
    tanggal.dispose();
    jumlahPenumpang.dispose();
    tipe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (profile == null || (profile != null && profile['role'] == 'Pelanggan'))
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2459A9),
                    ),
                    height: 400,
                    width: width,
                  ),
                if (profile == null || (profile != null && profile['role'] == 'Pelanggan'))
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 80, bottom: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello ${profile != null ? profile['namaLengkap'] : 'Guest'},',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                const SizedBox(height: 8),
                                const Text(
                                  'Booking travel sekarang',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                            Material(
                              elevation: 1,
                              borderRadius: BorderRadius.circular(50),
                              clipBehavior: Clip.hardEdge,
                              child: Image.network(
                                '${dotenv.env['RESTFUL_API']}/account/foto-profil/${profile != null ? profile['gambar'] : 'default.png'}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.error),
                                    SizedBox(height: 5),
                                    Text(
                                      'Image not loaded',
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        Container(
                          clipBehavior: Clip.hardEdge,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          child: Column(
                            children: [
                              InputComponent(
                                controller: from,
                                label: 'Asal',
                                hintText: 'Pilih Asal',
                                errorText: fromError,
                                readOnly: true,
                                onTap: () => destinasi(from, destination, fromId, destinationId, width, height, 'Asal'),
                                prefixIcon: Icons.my_location_outlined,
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF2459A9),
                                child: IconButton(
                                  onPressed: () {
                                    final String asal = from.text;
                                    final String asalId = fromId.text;
                                    final String tujuan = destination.text;
                                    final String tujuanId = destinationId.text;

                                    if (mounted) {
                                      setState(() {
                                        from.text = tujuan;
                                        destination.text = asal;
                                        fromId.text = tujuanId;
                                        destinationId.text = asalId;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.swap_calls_rounded),
                                  color: Colors.white,
                                ),
                              ),
                              InputComponent(
                                controller: destination,
                                label: 'Tujuan',
                                hintText: 'Pilih Tujuan',
                                errorText: destinationError,
                                readOnly: true,
                                onTap: () => destinasi(from, destination, fromId, destinationId, width, height, 'Tujuan'),
                                prefixIcon: Icons.departure_board_rounded,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: (width - 72) * 0.5,
                                    child: InputComponent(
                                      label: 'Tanggal Berangkat',
                                      errorText: tanggalError,
                                      controller: tanggal,
                                      hintText: 'Ex: 2011-12-30',
                                      readOnly: true,
                                      onTap: getTanggal,
                                      prefixIcon: Icons.calendar_month,
                                    ),
                                  ),
                                  SizedBox(
                                    width: (width - 72) * 0.5,
                                    child: InputComponent(
                                      controller: jumlahPenumpang,
                                      label: 'Jumlah Penumpang',
                                      errorText: jumlahPenumpangError,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      prefixIcon: Icons.person,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SelectComponent(label: 'Tipe', controller: tipe, opsi: opsiTipe, errorText: tipeError),
                              const SizedBox(height: 10),
                              ButtonComponent(
                                label: 'Cari Jadwal Keberangkatan',
                                onClick: () {
                                  if (profile != null) {
                                    carikan();
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else if (profile != null && profile['role'] != 'Pelanggan')
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2459A9),
                    ),
                    child: SafeArea(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daftar Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 20),
                            Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (profile['role'] == 'Admin')
                                  HomeMenuComponent(
                                    icon: IconlyBold.discount,
                                    nama: 'Promo',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PromoScreen())),
                                  ),
                                if (profile['role'] == 'Admin')
                                  HomeMenuComponent(
                                    icon: IconlyBold.bag,
                                    nama: 'Bank',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BankScreen())),
                                  ),
                                if (profile['role'] == 'Admin')
                                  HomeMenuComponent(
                                    icon: IconlyBold.document,
                                    nama: 'Kategori',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KategoriScreen())),
                                  ),
                                if (profile['role'] == 'Admin')
                                  HomeMenuComponent(
                                    icon: IconlyBold.paper,
                                    nama: 'Berita',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BeritaScreen())),
                                  ),
                                if (profile['role'] == 'Admin')
                                  HomeMenuComponent(
                                    icon: IconlyBold.location,
                                    nama: 'Tujuan',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TujuanScreen())),
                                  ),
                                if (profile['role'] == 'Admin')
                                  HomeMenuComponent(
                                    icon: Icons.flag_rounded,
                                    nama: 'Travel',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelScreen())),
                                  ),
                                if (profile['role'] != 'Supir')
                                  HomeMenuComponent(
                                    icon: Icons.people_alt,
                                    nama: 'User',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserScreen())),
                                  ),
                                if (profile['role'] != 'Supir')
                                  HomeMenuComponent(
                                    icon: Icons.car_rental_rounded,
                                    nama: 'Mobil',
                                    onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MobilScreen())),
                                  ),
                                HomeMenuComponent(
                                  icon: IconlyBold.bookmark,
                                  nama: 'Jadwal',
                                  onClick: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JadwalScreen())),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
            Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tujuan Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DaftarTujuanPage(),
                          ),
                        ),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 25,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: listTujuan
                          .map((val) => TujuanCard(
                              id: val['id'],
                              thumbnail: "${dotenv.env['RESTFUL_API']}/tujuan/gambar/${val['id']}",
                              nama: val['namaLengkap'],
                              deskripsi: val['deskripsi'],
                              width: width))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Berita',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DaftarBeritaPage(),
                          ),
                        ),
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 25,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: berita,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
