import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/page/form_travel.dart';
import 'package:tripvel/provider/auth_provider.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with AutomaticKeepAliveClientMixin<TravelScreen> {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController cari;
  late int sortColumnIndex;
  late bool isAscending;
  late List<Map<String, dynamic>> column;
  late List<DataRow> listTravel;
  late int jumlahData;
  late int totalData;
  late int totalPage;
  late int page;
  late int limit;
  late String? token;
  late dynamic profile;
  Timer? _timer;

  Future<void> getTravel() async {
    if (mounted) {
      setState(() {
        listTravel = [];
        jumlahData = 0;
        totalData = 0;
      });
    }

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['RESTFUL_API']}/travel?offset=${(page - 1) * limit}&limit=$limit&order={"index":"${column[sortColumnIndex]['data']}","order":"${isAscending == true ? 'asc' : 'desc'}"}${cari.text != '' ? '&search=${cari.text}' : ''}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<DataRow> tempTravel = [];

        for (var i = 0; i < responseBody['data'].length; i++) {
          final data = responseBody['data'][i];
          tempTravel.add(
            DataRow(
              cells: [
                DataCell(Text((((page - 1) * limit) + (i + 1)).toString())),
                DataCell(
                  ClipOval(
                    child: Image.network(
                      '${dotenv.env['RESTFUL_API']}/travel/gambar/${data['id']}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 40),
                    ),
                  ),
                ),
                DataCell(Text(data['nama'])),
                DataCell(Text(data['lokasi'])),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormTravelPage(refresh: getTravel, id: data['id']),
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
            listTravel.addAll(tempTravel);
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
    sortColumnIndex = 2;
    isAscending = false;
    column = [
      {
        'name': 'No',
        'data': null,
      },
      {
        'name': 'Gambar',
        'data': null,
      },
      {
        'name': 'Nama',
        'data': 'nama',
      },
      {
        'name': 'Lokasi',
        'data': 'lokasi',
      },
      {
        'name': 'Aksi',
        'data': null,
      }
    ];

    listTravel = [];
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

      getTravel();
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
              getTravel();
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

    getTravel();
  }

  void onSearch() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) {
        setState(() {
          page = 1;
        });
      }
      await getTravel();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Travel'),
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
                        const Text('Untuk melihat travel dengan lengkap, anda dapat menggeser ke kanan layar',
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
                            IconButton(onPressed: getTravel, icon: const Icon(Icons.refresh_rounded))
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
                    rows: listTravel,
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormTravelPage(refresh: getTravel))),
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
