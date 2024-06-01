import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/constant/map_constants.dart';
import 'package:http/http.dart' as http;
import 'package:tripvel/provider/auth_provider.dart';

class RutePenjemputanPage extends StatefulWidget {
  final int id;

  const RutePenjemputanPage({
    super.key,
    required this.id,
  });

  @override
  State<RutePenjemputanPage> createState() => _RutePenjemputanPageState();
}

class _RutePenjemputanPageState extends State<RutePenjemputanPage> {
  late MapController mapController;
  late final String accessToken;
  late LatLng center;
  late double _latitude;
  late double _longitude;
  late double? _latitudeSupir;
  late double? _longitudeSupir;
  late Map<String, dynamic>? data;
  late List<LatLng>? listDirection;

  Future<void> getTransaksi() async {
    final response = await http.get(
      Uri.parse("${dotenv.env['RESTFUL_API']}/transaksi/${widget.id}"),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          data = responseBody;
          center = LatLng(double.parse(responseBody['latitude'].toString()), double.parse(responseBody['longitude'].toString()));
          mapController.move(center, 16);
          _latitude = double.parse(responseBody['latitude'].toString());
          _longitude = double.parse(responseBody['longitude'].toString());
          _latitudeSupir = double.parse(responseBody['jadwal']['supir']['latitude'].toString());
          _longitudeSupir = double.parse(responseBody['jadwal']['supir']['longitude'].toString());
        });
      }

      if (responseBody['jadwal']['supir']['latitude'] != null &&
          responseBody['jadwal']['supir']['longitude'] != null &&
          responseBody['statusPenjemputan'] == 'Sedang dalam Perjalanan') {
        await getDirection(_latitude, _longitude, _latitudeSupir!, _longitudeSupir!);
      }
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
      if (mounted) setState(() => listDirection = points);
    }
  }

  Future<void> handleChangePosition(MapPosition mapPosition, bool hasGesture) async {
    if (mounted) setState(() => center = mapPosition.center!);
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _latitude = 0;
    _longitude = 0;
    _latitudeSupir = null;
    _longitudeSupir = null;
    center = LatLng(0.5070667, 101.4477783);
    listDirection = null;
    data = null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        accessToken = authProvider.accessToken!;
      });
      getTransaksi();
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
        title: const Text('Rute Penjemputan'),
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
                markers: [
                  Marker(point: LatLng(_latitude, _longitude), builder: (context) => const Icon(Icons.my_location_rounded)),
                  if (_latitudeSupir != null && _longitudeSupir != null)
                    Marker(point: LatLng(_latitudeSupir!, _longitudeSupir!), builder: (context) => const Icon(Icons.electric_car)),
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
          if (data != null)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                ),
                padding: const EdgeInsets.only(top: 20, bottom: 25, left: 20, right: 20),
                child: Row(
                  children: [
                    Image.network(
                      '${dotenv.env['RESTFUL_API']}/account/foto-profil/${data!['jadwal']['supir']['gambar']}',
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
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data!['jadwal']['supir']['namaLengkap'],
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${data!['jadwal']['mobil']['platNomor']}",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF2459A9)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${data!['jadwal']['mobil']['merek']} ${data!['jadwal']['mobil']['model']} (${data!['jadwal']['mobil']['warna']})",
                          style: const TextStyle(fontSize: 15, color: Color(0xFF6C757D)),
                        ),
                      ],
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
