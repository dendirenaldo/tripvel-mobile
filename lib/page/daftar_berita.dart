import 'dart:convert';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/component/input_component.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tripvel/card/daftar_berita_card.dart';

class DaftarBeritaPage extends StatefulWidget {
  const DaftarBeritaPage({super.key});

  @override
  State<DaftarBeritaPage> createState() => _DaftarBeritaPageState();
}

class _DaftarBeritaPageState extends State<DaftarBeritaPage> {
  late ScrollController _scrollController;
  late TextEditingController cari;
  late bool _isLoading;
  late bool _isLoadingRefresh;
  late List<DaftarBeritaCard> berita;
  late int limit;
  late int totalData;
  late bool initFilter;

  Future<void> getBerita() async {
    if (initFilter == true && mounted) {
      setState(() {
        berita = [];
        totalData = 1;
        initFilter = false;
      });
    }
    if (mounted) setState(() => _isLoading = true);
    if (totalData > berita.length) {
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['RESTFUL_API']}/berita?offset=${berita.length}&limit=$limit&order={"index":"createdAt","order":"desc"}${cari.text != '' ? '&search=${cari.text}' : ''}'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<DaftarBeritaCard> tempBerita = [];

        for (var e in responseBody['data']) {
          tempBerita.add(DaftarBeritaCard(
            id: e['id'],
            title: e['judul'],
            deskripsi: e['deskripsi'],
            thumbnail: "${dotenv.env['RESTFUL_API']}/berita/gambar/${e['id']}",
            authorName: e['auth']['namaLengkap'],
            authorImage: "${dotenv.env['RESTFUL_API']}/auth/gambar/${e['auth']['id']}",
          ));
        }

        Future.delayed(
          Duration(milliseconds: totalData > 1 ? 850 : 0),
          () {
            if (mounted) {
              setState(() {
                totalData = responseBody['totalData'];
                berita.addAll(tempBerita);
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
                          'Anda dapat mencari berita yang akan ditampilkan pada daftar di layar!',
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
                            hintText: 'Cari berdasarkan nama, tanggal, dan author',
                            onSubmit: (string) {
                              if (mounted) setState(() => initFilter = true);
                              getBerita();
                              Navigator.of(context).pop();
                            }),
                        const SizedBox(height: 20),
                        ButtonComponent(
                            label: 'Simpan',
                            onClick: () {
                              if (mounted) setState(() => initFilter = true);
                              getBerita();
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
    berita = [];
    limit = 10;
    totalData = 1;
    _isLoading = true;
    _isLoadingRefresh = false;
    initFilter = true;
    getBerita();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
            !_isLoading &&
            !_scrollController.position.isScrollingNotifier.value) {
          getBerita();
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
          'Berita',
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
                    berita = [];
                    limit = 5;
                    totalData = 1;
                    _isLoadingRefresh = true;
                  });
                }

                return Future<void>.delayed(const Duration(seconds: 1), getBerita);
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: berita.length + (_isLoading == true && _isLoadingRefresh == false && totalData != berita.length ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == berita.length && (_isLoading == true && _isLoadingRefresh == false) && totalData != berita.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return berita[index];
                },
              ),
            ),
          ),
          if (berita.isEmpty && _isLoading == false && _isLoadingRefresh == false)
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/vector_document.png',
                    width: width - 100,
                  ),
                  const Text('Tidak ada berita', style: TextStyle(fontSize: 13.5, color: Color(0xFF999999)), textScaleFactor: 1.0),
                ],
              ),
            )
        ],
      ),
    );
  }
}
