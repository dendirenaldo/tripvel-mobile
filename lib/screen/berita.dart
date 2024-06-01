import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/page/form_berita.dart';
import 'package:tripvel/provider/auth_provider.dart';

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> with AutomaticKeepAliveClientMixin<BeritaScreen> {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController cari;
  late int sortColumnIndex;
  late bool isAscending;
  late List<Map<String, dynamic>> column;
  late List<DataRow> listBerita;
  late int jumlahData;
  late int totalData;
  late int totalPage;
  late int page;
  late int limit;
  late String? token;
  late dynamic profile;
  Timer? _timer;

  Future<void> getBerita() async {
    if (mounted) {
      setState(() {
        listBerita = [];
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
          '${dotenv.env['RESTFUL_API']}/berita?offset=${(page - 1) * limit}&limit=$limit&order=$order${cari.text != '' ? '&search=${cari.text}' : ''}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<DataRow> tempBerita = [];

        for (var i = 0; i < responseBody['data'].length; i++) {
          final data = responseBody['data'][i];
          tempBerita.add(
            DataRow(
              cells: [
                DataCell(Text((((page - 1) * limit) + (i + 1)).toString())),
                DataCell(Text(data['judul'])),
                DataCell(Text(data['kategori']['nama'])),
                DataCell(Text(data['deskripsi'])),
                DataCell(Text(data['waktuMembaca'].toString())),
                DataCell(Text(data['auth']['namaLengkap'])),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormBeritaPage(refresh: getBerita, id: data['id']),
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
            listBerita.addAll(tempBerita);
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
      {
        'name': 'Judul',
        'data': 'judul',
      },
      {
        'name': 'Kategori',
        'data': ['kategori', 'nama'],
      },
      {
        'name': 'Deskripsi',
        'data': 'deskripsi',
      },
      {
        'name': 'Waktu Membaca',
        'data': 'waktuMembaca',
      },
      {
        'name': 'Penulis',
        'data': ['auth', 'nama_lengkap'],
      },
      {
        'name': 'Aksi',
        'data': null,
      },
    ];

    listBerita = [];
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

      if (mounted) setState(() => sortColumnIndex = 1);
      getBerita();
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
              getBerita();
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

    getBerita();
  }

  void onSearch() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) {
        setState(() {
          page = 1;
        });
      }
      await getBerita();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Berita'),
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
                        const Text('Untuk melihat berita dengan lengkap, anda dapat menggeser ke kanan layar',
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
                            IconButton(onPressed: getBerita, icon: const Icon(Icons.refresh_rounded))
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
                    rows: listBerita,
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormBeritaPage(refresh: getBerita))),
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
