import 'dart:convert';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripvel/card/daftar_tujuan_card.dart';

class DaftarTujuanPage extends StatefulWidget {
  const DaftarTujuanPage({super.key});

  @override
  State<DaftarTujuanPage> createState() => _DaftarTujuanPageState();
}

class _DaftarTujuanPageState extends State<DaftarTujuanPage> {
  late ScrollController _scrollController;
  late TextEditingController cari;
  late bool _isLoading;
  late bool _isLoadingRefresh;
  late List<DaftarTujuanCard> tujuan;
  late int limit;
  late int totalData;
  late bool initFilter;

  Future<void> getTujuan() async {
    if (initFilter == true && mounted) {
      setState(() {
        tujuan = [];
        totalData = 1;
        initFilter = false;
      });
    }
    if (mounted) setState(() => _isLoading = true);
    if (totalData > tujuan.length) {
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['RESTFUL_API']}/tujuan?offset=${tujuan.length}&limit=$limit&order={"index":"createdAt","order":"desc"}${cari.text != '' ? '&search=${cari.text}' : ''}'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<DaftarTujuanCard> tempTujuan = [];

        for (var e in responseBody['data']) {
          tempTujuan.add(DaftarTujuanCard(
            id: e['id'],
            title: e['namaLengkap'],
            deskripsi: e['deskripsi'],
            thumbnail: "${dotenv.env['RESTFUL_API']}/tujuan/gambar/${e['id']}",
          ));
        }

        Future.delayed(
          Duration(milliseconds: totalData > 1 ? 850 : 0),
          () {
            if (mounted) {
              setState(() {
                totalData = responseBody['totalData'];
                tujuan.addAll(tempTujuan);
                _isLoading = false;
                _isLoadingRefresh = false;
              });
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingRefresh = false;
          });
        }
      }
    }
  }

  void showFilter() {
    double width = MediaQuery.of(context).size.width;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                    width: double.infinity,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const Text(
                          'Filter',
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Anda dapat mencari tujuan yang akan ditampilkan pada daftar di layar!',
                          style: TextStyle(
                            color: Color(0xFF4E4E4E),
                            fontSize: 13,
                          ),
                          textScaleFactor: 1.0,
                        ),
                        const SizedBox(height: 15),
                        InputComponent(
                            controller: cari,
                            label: 'Pencarian',
                            hintText: 'Cari berdasarkan nama tujuan',
                            onSubmit: (string) {
                              if (mounted) setState(() => initFilter = true);
                              getTujuan();
                              Navigator.of(context).pop();
                            }),
                        const SizedBox(height: 20),
                        ButtonComponent(
                            label: 'Simpan',
                            onClick: () {
                              if (mounted) setState(() => initFilter = true);
                              getTujuan();
                              Navigator.of(context).pop();
                            }),
                        const SizedBox(height: 20),
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
                        child: const Divider(thickness: 6)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    cari = TextEditingController();
    tujuan = [];
    limit = 10;
    totalData = 1;
    _isLoading = true;
    _isLoadingRefresh = false;
    initFilter = true;
    getTujuan();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
            !_isLoading &&
            !_scrollController.position.isScrollingNotifier.value) {
          getTujuan();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    cari.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tujuan',
          style: TextStyle(color: Colors.black, fontSize: 15.3),
          textScaleFactor: 1.0,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: showFilter,
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: RefreshIndicator(
              onRefresh: () {
                if (mounted) {
                  setState(() {
                    tujuan = [];
                    limit = 5;
                    totalData = 1;
                    _isLoadingRefresh = true;
                  });
                }

                return Future<void>.delayed(const Duration(seconds: 1), getTujuan);
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: tujuan.length + (_isLoading == true && _isLoadingRefresh == false && totalData != tujuan.length ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == tujuan.length && (_isLoading == true && _isLoadingRefresh == false) && totalData != tujuan.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return tujuan[index];
                },
              ),
            ),
          ),
          if (tujuan.isEmpty && _isLoading == false && _isLoadingRefresh == false)
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/vector_document.png',
                    width: width - 100,
                  ),
                  const Text('Tidak ada tujuan', style: TextStyle(fontSize: 13.5, color: Color(0xFF999999)), textScaleFactor: 1.0),
                ],
              ),
            )
        ],
      ),
    );
  }
}
