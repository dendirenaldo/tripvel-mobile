import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/page/form_tujuan.dart';
import 'package:tripvel/provider/auth_provider.dart';

class TujuanScreen extends StatefulWidget {
  const TujuanScreen({super.key});

  @override
  State<TujuanScreen> createState() => _TujuanScreenState();
}

class _TujuanScreenState extends State<TujuanScreen> with AutomaticKeepAliveClientMixin<TujuanScreen> {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController cari;
  late int sortColumnIndex;
  late bool isAscending;
  late List<Map<String, dynamic>> column;
  late List<DataRow> listTujuan;
  late int jumlahData;
  late int totalData;
  late int totalPage;
  late int page;
  late int limit;
  late String? token;
  late dynamic profile;
  Timer? _timer;

  Future<void> getTujuan() async {
    if (mounted) {
      setState(() {
        listTujuan = [];
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
          '${dotenv.env['RESTFUL_API']}/tujuan?offset=${(page - 1) * limit}&limit=$limit&order=$order${cari.text != '' ? '&search=${cari.text}' : ''}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<DataRow> tempTujuan = [];

        for (var i = 0; i < responseBody['data'].length; i++) {
          final data = responseBody['data'][i];
          tempTujuan.add(
            DataRow(
              cells: [
                DataCell(Text((((page - 1) * limit) + (i + 1)).toString())),
                DataCell(Text(data['namaLengkap'])),
                DataCell(Text(data['namaSingkatan'])),
                DataCell(Text(data['longitude'].toStringAsFixed(5))),
                DataCell(Text(data['latitude'].toStringAsFixed(5))),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormTujuanPage(refresh: getTujuan, id: data['id']),
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
            listTujuan.addAll(tempTujuan);
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
    sortColumnIndex = 1;
    isAscending = false;
    column = [
      {
        'name': 'No',
        'data': null,
      },
      {
        'name': 'Nama Lengkap',
        'data': 'namaLengkap',
      },
      {
        'name': 'Nama Singkatan',
        'data': 'namaSingkatan',
      },
      {
        'name': 'Longitude',
        'data': 'longitude',
      },
      {
        'name': 'Latitude',
        'data': 'latitude',
      },
      {
        'name': 'Aksi',
        'data': null,
      }
    ];

    listTujuan = [];
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

      getTujuan();
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
              getTujuan();
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

    getTujuan();
  }

  void onSearch() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) {
        setState(() {
          page = 1;
        });
      }
      await getTujuan();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tujuan'),
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
                        const Text('Untuk melihat tujuan dengan lengkap, anda dapat menggeser ke kanan layar',
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
                            IconButton(onPressed: getTujuan, icon: const Icon(Icons.refresh_rounded))
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
                            onSort: item['name'] == 'No' || item['name'] == 'Gambar' || item['name'] == 'Aksi' ? null : onSort))
                        .toList(),
                    rows: listTujuan,
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormTujuanPage(refresh: getTujuan))),
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
