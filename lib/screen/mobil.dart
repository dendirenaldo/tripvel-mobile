import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/page/form_mobil.dart';
import 'package:tripvel/provider/auth_provider.dart';

class MobilScreen extends StatefulWidget {
  const MobilScreen({super.key});

  @override
  State<MobilScreen> createState() => _MobilScreenState();
}

class _MobilScreenState extends State<MobilScreen> with AutomaticKeepAliveClientMixin<MobilScreen> {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController cari;
  late int sortColumnIndex;
  late bool isAscending;
  late List<Map<String, dynamic>> column;
  late List<DataRow> listMobil;
  late int jumlahData;
  late int totalData;
  late int totalPage;
  late int page;
  late int limit;
  late String? token;
  late dynamic profile;
  Timer? _timer;

  Future<void> getMobil() async {
    if (mounted) {
      setState(() {
        listMobil = [];
        jumlahData = 0;
        totalData = 0;
      });
    }

    final Object order = jsonEncode({
      'index': column[sortColumnIndex]['data'],
      'order': isAscending == true ? 'asc' : 'desc',
    });
    final response = await http.get(
      Uri.parse(
          '${dotenv.env['RESTFUL_API']}/mobil?offset=${(page - 1) * limit}&limit=$limit&order=$order${cari.text != '' ? '&search=${cari.text}' : ''}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<DataRow> tempMobil = [];

        for (var i = 0; i < responseBody['data'].length; i++) {
          final data = responseBody['data'][i];
          tempMobil.add(
            DataRow(
              cells: [
                DataCell(Text((((page - 1) * limit) + (i + 1)).toString())),
                if (profile['role']! == 'Admin') DataCell(Text(data['travel']['nama'])),
                DataCell(Text(data['merek'])),
                DataCell(Text(data['model'])),
                DataCell(Text(data['platNomor'])),
                DataCell(Text(data['warna'])),
                DataCell(Text(data['jumlahPenumpang'].toString())),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormMobilPage(refresh: getMobil, id: data['id']),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (mounted) {
          setState(() {
            listMobil.addAll(tempMobil);
            jumlahData = responseBody['totalRow'];
            totalData = responseBody['totalData'];
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    cari = TextEditingController();
    sortColumnIndex = 0;
    isAscending = false;
    column = [
      {
        'name': 'No',
        'data': null,
      },
    ];

    listMobil = [];
    totalData = 0;
    jumlahData = 0;
    totalPage = 1;
    page = 1;
    limit = 5;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (mounted) {
        setState(() {
          profile = authProvider.profile!;
          token = authProvider.accessToken;
        });
      }

      if (profile['role']! == 'Admin') {
        column.add({
          'name': 'Travel',
          'data': ['travel', 'nama'],
        });
      }

      column.addAll([
        {
          'name': 'Merek',
          'data': 'merek',
        },
        {
          'name': 'Model',
          'data': 'model',
        },
        {
          'name': 'Plat Nomor',
          'data': 'platNomor',
        },
        {
          'name': 'Warna',
          'data': 'warna',
        },
        {
          'name': 'Kapasitas',
          'data': 'jumlahPenumpang',
        },
        {
          'name': 'Aksi',
          'data': null,
        }
      ]);
      if (mounted) setState(() => sortColumnIndex = 1);
      getMobil();
    });
  }

  @override
  void dispose() {
    cari.dispose();
    super.dispose();
  }

  List<Widget> pagination() {
    List<Widget> listPagination = [];
    final minPage = page - 2;
    final maxPage = page + 2;

    for (var i = (minPage < 1 ? 1 : minPage); i <= (maxPage > (totalData / limit).ceil() ? (totalData / limit).ceil() : maxPage); i++) {
      listPagination.add(
        InkWell(
          onTap: () {
            if (page != i) {
              if (mounted) setState(() => page = i);
              getMobil();
            }
          },
          child: Ink(
            child: Container(
              padding: const EdgeInsets.all(12),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Color(0xFF2459A9),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                i.toString(),
                style: TextStyle(
                  color: i == page ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: i == page ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
      listPagination.add(const SizedBox(width: 5));
    }

    return listPagination;
  }

  void onSort(int index, bool asc) {
    if (mounted) {
      setState(() {
        sortColumnIndex = index;
        isAscending = asc;
      });
    }

    getMobil();
  }

  void onSearch() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) {
        setState(() {
          page = 1;
        });
      }
      await getMobil();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mobil'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width - 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Untuk melihat mobil dengan lengkap, anda dapat menggeser ke kanan layar',
                            style: TextStyle(fontSize: 13, color: Colors.black45)),
                        const SizedBox(height: 10),
                        InputComponent(controller: cari, hintText: 'Cari', prefixIcon: Icons.search_rounded, listen: onSearch),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: width * 0.8,
                              child: Text('Menampilkan ${jumlahData.toString()} dari $totalData data',
                                  style: const TextStyle(fontSize: 13, color: Colors.black45)),
                            ),
                            IconButton(onPressed: getMobil, icon: const Icon(Icons.refresh_rounded))
                          ],
                        )
                      ],
                    ),
                  ),
                  DataTable(
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: isAscending,
                    // border: TableBorder.all(),
                    columns: column
                        .map((item) => DataColumn(
                            label: Text(item['name'], textAlign: TextAlign.center),
                            onSort: item['name'] == 'No' || item['name'] == 'Aksi' ? null : onSort))
                        .toList(),
                    rows: listMobil,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width - 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: pagination(),
                        ),
                        IconButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormMobilPage(refresh: getMobil))),
                            icon: const Icon(Icons.add_rounded)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
