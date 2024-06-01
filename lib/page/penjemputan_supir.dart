// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/constant/map_constants.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/functionality/map_functionality.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class PenjemputanSupirPage extends StatefulWidget {
  final int id;

  const PenjemputanSupirPage({
    super.key,
    required this.id,
  });

  @override
  State<PenjemputanSupirPage> createState() => _PenjemputanSupirPageState();
}

class _PenjemputanSupirPageState extends State<PenjemputanSupirPage> {
  late Timer? _timer;
  late MapController mapController;
  late final String accessToken;
  late Position? _currentLocation;
  late dynamic profile;
  late List<dynamic>? listTransaksi;
  late dynamic transaksi;
  late List<LatLng>? listDirection;
  late double? _latitude;
  late double? _longitude;

  void _startGetLocation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setLocation();
    });
  }

  Future<void> setLocation() async {
    final locationData = (await MapFunctionality.getCurrentLocation());

    if (locationData != null && mounted) {
      setState(() => _currentLocation = locationData);
      mapController.move(LatLng(locationData.latitude, locationData.longitude), mapController.zoom);

      final response = await http.put(
        Uri.parse("${dotenv.env['RESTFUL_API']}/account/change-location"),
        body: {
          'latitude': locationData.latitude.toString(),
          'longitude': locationData.longitude.toString(),
        },
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (transaksi != null && transaksi['statusPenjemputan'] == 'Sedang dalam Perjalanan') {
        await getDirection(transaksi['latitude'], transaksi['longitude'], locationData.latitude, locationData.longitude);
      }
    }
  }

  Future<void> getData() async {
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/jadwal/${widget.id}"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (mounted) setState(() => listTransaksi = responseBody['transaksi']);
    }
  }

  Future<void> getDirection(double latitude, double longitude, double latitudeSupir, double longitudeSupir) async {
    final response = await http.get(
      Uri.parse(
          "https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf624867cb035da5b34146a075c6ce86bf0041&start=${longitude},${latitude}&end=${longitudeSupir},${latitudeSupir}"),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> listPoint = responseBody['features'][0]['geometry']['coordinates'];
      final List<LatLng> points = listPoint.map((val) => LatLng(double.parse(val[1].toString()), double.parse(val[0].toString()))).toList();
      if (mounted && transaksi != null) setState(() => listDirection = points);
    }
  }

  Future<void> pilih(int id, {BuildContext? context}) async {
    if (context != null) Navigator.of(context).pop();
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi/$id"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          transaksi = responseBody;
          _latitude = responseBody['latitude'];
          _longitude = responseBody['longitude'];
        });
      }

      if (responseBody['statusPenjemputan'] == null) ubahStatus(id, 'Sedang dalam Perjalanan');

      if (responseBody['statusPenjemputan'] == 'Sedang dalam Perjalanan' && _currentLocation != null) {
        await getDirection(responseBody['latitude'], responseBody['longitude'], _currentLocation!.latitude, _currentLocation!.longitude);
      }
    }
  }

  Future<void> ubahStatus(int id, String statusPenjemputan) async {
    final response = await http.put(
      Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi/change-status-penjemputan/$id"),
      body: {'statusPenjemputan': statusPenjemputan},
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      getData();
      pilih(id);
    }
  }

  Future<void> showListPenumpang() async {
    double width = MediaQuery.of(context).size.width;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                SingleChildScrollView(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.only(top: 35, bottom: 25, left: 20, right: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Daftar Penjemputan',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (listTransaksi!.isNotEmpty)
                          ...listTransaksi!.map(
                            (val) => Column(
                              children: [
                                if (listTransaksi!.indexOf(val) != 0) const SizedBox(height: 5),
                                if (listTransaksi!.indexOf(val) != 0) const Divider(color: Colors.black),
                                Material(
                                  child: InkWell(
                                    onTap: () => pilih(val['id'], context: context),
                                    child: Ink(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            val['alamat'],
                                            style: const TextStyle(fontSize: 15),
                                            textScaleFactor: 1.0,
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            margin: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ...val['transaksiList'].map(
                                                  (value) => Row(
                                                    children: [
                                                      Text(
                                                        value['nomorKursi'],
                                                        style: const TextStyle(
                                                          color: Color(0xFF2459A9),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        textScaleFactor: 1.0,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        value['namaLengkap'],
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                        textScaleFactor: 1.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(11)),
                                              color: val['statusPenjemputan'] == 'Selesai' || val['statusPenjemputan'] == 'Sudah Dijemput'
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            child: Text(
                                              val?['statusPenjemputan'] != null ? val['statusPenjemputan'] : 'Belum Dijemput',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              textScaleFactor: 1.0,
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
                      ],
                    ),
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
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = null;
    mapController = MapController();
    _currentLocation = null;
    profile = null;
    listTransaksi = null;
    transaksi = null;
    listDirection = null;
    _latitude = null;
    _longitude = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        accessToken = authProvider.accessToken!;
        profile = authProvider.getAccount();
      });

      getData();
    });

    setLocation();
    _startGetLocation();
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
        title: const Text('Penjemputan'),
        centerTitle: false,
        backgroundColor: const Color(0xFF2459A9),
        actions: [
          IconButton(onPressed: showListPenumpang, icon: const Icon(Icons.list)),
        ],
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
              center: LatLng(
                _currentLocation != null ? _currentLocation!.latitude : (profile != null ? profile['latitude'] : 0),
                _currentLocation != null ? _currentLocation!.longitude : (profile != null ? profile['longitude'] : 0),
              ),
              onPositionChanged: (MapPosition position, bool hasGesture) {},
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
                markers: [
                  Marker(
                    point: LatLng(_currentLocation != null ? _currentLocation!.latitude : (profile != null ? profile['latitude'] : 0),
                        _currentLocation != null ? _currentLocation!.longitude : (profile != null ? profile['longitude'] : 0)),
                    builder: (context) => const Icon(Icons.my_location_rounded),
                  ),
                  if (_latitude != null && _longitude != null)
                    Marker(point: LatLng(_latitude!, _longitude!), builder: (context) => const Icon(Icons.location_on)),
                ],
              ),
              PolylineLayer(
                polylineCulling: false,
                polylines: [
                  if (listDirection != null && listDirection!.isNotEmpty)
                    Polyline(
                      points: listDirection!,
                      color: Colors.blue,
                      strokeWidth: 3,
                    ),
                ],
              ),
            ],
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
          if (transaksi != null)
            Positioned(
              left: 0,
              bottom: 0,
              width: width,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  color: Colors.white,
                ),
                width: double.infinity,
                padding: const EdgeInsets.only(top: 25, bottom: 25, left: 20, right: 20),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Informasi Pemesan',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              '${dotenv.env['RESTFUL_API']}/auth/gambar/${transaksi['user']['id']}',
                              width: 45,
                              height: 45,
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
                            const SizedBox(width: 10),
                            SizedBox(
                              width: width - 95,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${transaksi['user']['namaLengkap']} ${transaksi['user']['nomorPonsel'] != null ? '(0${transaksi['user']['nomorPonsel']})' : ''}',
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      textScaleFactor: 1.0),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(11)),
                                      color: transaksi['statusPenjemputan'] == 'Selesai' || transaksi['statusPenjemputan'] == 'Sudah Dijemput'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    child: Text(
                                      transaksi?['statusPenjemputan'] != null ? transaksi['statusPenjemputan'] : 'Belum Dijemput',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textScaleFactor: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(transaksi['alamat'], style: const TextStyle(fontSize: 15), textScaleFactor: 1.0),
                        const SizedBox(height: 5),
                        Text(
                          'Rp${GeneralFunctionality.rupiah(transaksi['harga'] * transaksi['transaksiList'].length)} - ${transaksi['metodePembayaran']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textScaleFactor: 1.0,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Daftar Penumpang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textScaleFactor: 1.0,
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...transaksi['transaksiList'].map(
                              (value) => Row(
                                children: [
                                  Text(
                                    value['nomorKursi'],
                                    style: const TextStyle(
                                      color: Color(0xFF2459A9),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textScaleFactor: 1.0,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    value['namaLengkap'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (transaksi['statusPenjemputan'] == null || transaksi['statusPenjemputan'] == 'Sedang dalam Perjalanan')
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              ButtonComponent(
                                label: 'Selesai Penjemputan',
                                onClick: () async {
                                  await ubahStatus(transaksi['id'], 'Sudah Dijemput');
                                  await getData();
                                  if (mounted) {
                                    setState(() {
                                      transaksi = null;
                                      listDirection = null;
                                      _latitude = null;
                                      _longitude = null;
                                    });
                                  }
                                },
                              ),
                            ],
                          )
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              transaksi = null;
                              listDirection = null;
                              _latitude = null;
                              _longitude = null;
                            });
                          }
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
