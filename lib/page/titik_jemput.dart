import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconly/iconly.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/constant/map_constants.dart';
import 'package:tripvel/functionality/map_functionality.dart';
import 'package:tripvel/page/pilih_order.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class TitikJemputPage extends StatefulWidget {
  final int id;
  final int travelId;
  final String travel;
  final String tanggal;
  final String asalSingkatan;
  final String asalLengkap;
  final String tujuanSingkatan;
  final String tujuanLengkap;
  final String jamBerangkat;
  final String jamTiba;
  final int jumlahPenumpang;
  final int harga;

  const TitikJemputPage({
    super.key,
    required this.id,
    required this.travelId,
    required this.travel,
    required this.tanggal,
    required this.asalSingkatan,
    required this.asalLengkap,
    required this.tujuanSingkatan,
    required this.tujuanLengkap,
    required this.jamBerangkat,
    required this.jamTiba,
    required this.jumlahPenumpang,
    required this.harga,
  });

  @override
  State<TitikJemputPage> createState() => _TitikJemputPageState();
}

class _TitikJemputPageState extends State<TitikJemputPage> {
  late MapController mapController;
  late LatLng center;
  late String placeName;
  late String accessToken;
  Timer? _timer;

  Future<void> getPlace() async {
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/jadwal/${widget.id}"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['id'] != null) {
        center = LatLng(double.parse(responseBody['asal']['latitude'].toString()), double.parse(responseBody['asal']['longitude'].toString()));
        mapController.move(center, 15);
        getPlaceName(double.parse(responseBody['asal']['latitude'].toString()), double.parse(responseBody['asal']['longitude'].toString()));
        setLocation();
      }
    }
  }

  Future<void> setLocation() async {
    final locationData = (await MapFunctionality.getCurrentLocation());

    if (locationData != null && mounted) {
      setState(() {
        center = LatLng(locationData.latitude, locationData.longitude);
        mapController.move(center, 15);
      });
    }
  }

  Future<void> handleChangePosition(MapPosition mapPosition, bool hasGesture) async {
    if (mounted) setState(() => center = mapPosition.center!);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 200), () async => await getPlaceName(center.latitude, center.longitude));
  }

  Future<void> getPlaceName(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/tujuan/lokasi?latitude=$latitude&longitude=$longitude"),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['placeName'] != null) {
        if (mounted) setState(() => placeName = responseBody['placeName']);
      }
    }
  }

  void lanjut() {
    if (placeName != '') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PilihOrderPage(
                    id: widget.id,
                    travelId: widget.travelId,
                    travel: widget.travel,
                    tanggal: widget.tanggal,
                    asalLengkap: widget.asalLengkap,
                    asalSingkatan: widget.asalSingkatan,
                    tujuanLengkap: widget.tujuanLengkap,
                    tujuanSingkatan: widget.tujuanSingkatan,
                    jamBerangkat: widget.jamBerangkat,
                    jamTiba: widget.jamTiba,
                    jumlahPenumpang: widget.jumlahPenumpang,
                    harga: widget.harga,
                    latitude: center.latitude,
                    longitude: center.longitude,
                    placeName: placeName,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Gagal"),
            content: const Text("Mohon dipilih lokasi yang benar!"),
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

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    center = LatLng(0.5070667, 101.4477783);
    placeName = '';
    accessToken = '';

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        accessToken = authProvider.accessToken!;
      });
      getPlace();
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titik Jemput'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
      ),
      backgroundColor: Colors.blueGrey[50],
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 8,
              maxZoom: 18,
              zoom: 16,
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              center: center,
              onPositionChanged: handleChangePosition,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://api.mapbox.com/styles/v1/dendirenaldo/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                additionalOptions: const {
                  'mapStyleId': MapConstants.mapBoxStyleId,
                  'accessToken': MapConstants.mapBoxAccessToken,
                },
              ),
              MarkerLayer(
                markers: [Marker(point: center, builder: (context) => const Icon(IconlyBold.location))],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Titik Penjemputan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                  const SizedBox(height: 15),
                  Text(placeName, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF291F1f))),
                  const SizedBox(height: 20),
                  ButtonComponent(
                    label: 'Lanjutkan',
                    onClick: lanjut,
                    width: width - 36,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: 15,
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(right: 10),
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  mapController.move(mapController.center, mapController.zoom + 1);
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ),
                            const SizedBox(height: 0.5),
                            Container(
                              padding: const EdgeInsets.only(top: 5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  mapController.move(mapController.center, mapController.zoom - 1);
                                },
                                icon: const Icon(Icons.remove),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
