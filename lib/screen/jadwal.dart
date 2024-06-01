import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/page/form_jadwal.dart';
import 'package:tripvel/page/penjemputan_supir.dart';
import 'package:tripvel/provider/auth_provider.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> with AutomaticKeepAliveClientMixin<JadwalScreen> {
  @override
  bool get wantKeepAlive => true;
  late final TextEditingController cari;
  late int sortColumnIndex;
  late bool isAscending;
  late List<Map<String, dynamic>> column;
  late List<DataRow> listJadwal;
  late int jumlahData;
  late int totalData;
  late int totalPage;
  late int page;
  late int limit;
  late String? token;
  late dynamic profile;
  Timer? _timer;

  Future<void> getJadwal() async {
    if (mounted) {
      setState(() {
        listJadwal = [];
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
          '${dotenv.env['RESTFUL_API']}/jadwal?offset=${(page - 1) * limit}&limit=$limit&order=$order${cari.text != '' ? '&search=${cari.text}' : ''}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['data'].isNotEmpty) {
        final List<DataRow> tempJadwal = [];

        for (var i = 0; i < responseBody['data'].length; i++) {
          final data = responseBody['data'][i];
          tempJadwal.add(
            DataRow(
              cells: [
                DataCell(Text((((page - 1) * limit) + (i + 1)).toString())),
                DataCell(Text(GeneralFunctionality.tanggalIndonesiaPendek(data['tanggal']))),
                if (profile['role']! == 'Admin') DataCell(Text(data['travel']['nama'])),
                DataCell(Text('${data['mobil']['merek']} ${data['mobil']['model']} (${data['mobil']['platNomor']})')),
                DataCell(Text(data['supir']['namaLengkap'])),
                DataCell(Text(data['asal']['namaLengkap'])),
                DataCell(Text(data['tujuan']['namaLengkap'])),
                DataCell(Text('Rp${GeneralFunctionality.rupiah(data['harga'])}')),
                if (profile['role']! != 'Supir')
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormJadwalPage(refresh: getJadwal, id: data['id']),
                        ),
                      ),
                    ),
                  ),
                if (profile['role']! == 'Supir' && data['tanggal'].toString().substring(0, 10) == DateFormat('yyyy-MM-dd').format(DateTime.now()))
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PenjemputanSupirPage(id: data['id']),
                        ),
                      ),
                    ),
                  ),
                if (profile['role']! == 'Supir' && data['tanggal'].toString().substring(0, 10) != DateFormat('yyyy-MM-dd').format(DateTime.now()))
                  DataCell(Container()),
              ],
            ),
          );
        }

        if (mounted) {
          setState(() {
            listJadwal.addAll(tempJadwal);
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
        'name': 'Tanggal',
        'data': 'tanggal',
      },
    ];

    listJadwal = [];
    totalData = 0;
    jumlahData = 0;
    totalPage = 1;
    page = 1;
    limit = 5;
    profile = null;

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
          'data': 'travel.nama',
        });
      }

      column.addAll([
        {
          'name': 'Mobil',
          'data': ['mobil', 'merek'],
        },
        {
          'name': 'Supir',
          'data': ['supir', 'nama_lengkap'],
        },
        {
          'name': 'Asal',
          'data': ['asal', 'namaLengkap'],
        },
        {
          'name': 'Tujuan',
          'data': ['tujuan', 'namaLengkap'],
        },
        {
          'name': 'Harga',
          'data': 'harga',
        },
        {
          'name': 'Aksi',
          'data': null,
        }
      ]);

      getJadwal();
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
              getJadwal();
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

    getJadwal();
  }

  void onSearch() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () async {
      if (mounted) {
        setState(() {
          page = 1;
        });
      }
      await getJadwal();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Jadwal'),
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
                        const Text('Untuk melihat jadwal dengan lengkap, anda dapat menggeser ke kanan layar',
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
                            IconButton(onPressed: getJadwal, icon: const Icon(Icons.refresh_rounded))
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
                    rows: listJadwal,
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
                        if (profile != null && profile['role']! != 'Supir')
                          IconButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FormJadwalPage(refresh: getJadwal))),
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
