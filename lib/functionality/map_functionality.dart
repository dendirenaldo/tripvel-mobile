import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapFunctionality {
  static Future<Position> getCurrentLocation() async {
    LocationPermission permission;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Request to turn on location services
      bool result = await Geolocator.openLocationSettings();
      if (!result) {
        throw Exception('Location services are disabled.');
      }
    }

    // Check for location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      // Request for location permissions
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        throw Exception('Location permissions are denied (actual value: $permission).');
      }
    }

    // Get the current location
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // ignore: non_constant_identifier_names
  Marker MarkerPerson(double latitude, double longitude, {String? image, String? nama, int? jumlah}) {
    return Marker(
      height: 75,
      width: 75,
      point: LatLng(latitude, longitude),
      builder: (context) => GestureDetector(
        onTap: () {
          // Do something when marker is tapped
          print(context);
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            if (nama != null && jumlah != null)
              Container(
                clipBehavior: Clip.hardEdge,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(child: Text(jumlah.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              ),
            if (nama == null)
              const Icon(
                Icons.location_pin,
                size: 32,
                color: Color(0xFF0476D6),
              ),
            if (image != null)
              Positioned(
                top: -40,
                child: ClipOval(
                  child: Image.network(
                    image,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (nama != null)
              Positioned(
                top: 50,
                child: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Future<List<Marker>> showPersonOnMarker(MapPosition position, MapController controller, dynamic profile, String token) async {
    LatLngBounds? visibleBounds = controller.bounds;
    final List<Marker> marker = [];

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['RESTFUL_API']}/${profile['role'] == 'Pemilih' ? 'account' : 'pemilihan'}/find-person-in-bound?latSW=${visibleBounds!.southWest.latitude}&latNE=${visibleBounds.northEast.latitude}&lngSW=${visibleBounds.southWest.longitude}&lngNE=${visibleBounds.northEast.longitude}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);

      if (responseBody.isNotEmpty) {
        for (var i = 0; i < responseBody.length; i++) {
          double? latitude;
          double? longitude;
          String? gambar;

          if (profile['role'] == 'Pemilih') {
            gambar = '${dotenv.env['RESTFUL_API']}/account/foto-profil/${responseBody[i]['gambar']}';
            latitude = responseBody[i]['latitude'];
            longitude = responseBody[i]['longitude'];
          } else if (profile['role'] == 'Caleg') {
            gambar = '${dotenv.env['RESTFUL_API']}/account/foto-profil/${responseBody[i]['auth']['gambar']}';
            latitude = responseBody[i]['auth']['latitude'];
            longitude = responseBody[i]['auth']['longitude'];
          }

          LatLng latLng = LatLng(latitude!, longitude!);

          if (visibleBounds.contains(latLng)) {
            marker.add(MarkerPerson(latitude, longitude, image: gambar));
          }
        }
      }
    }

    return marker;
  }

  Future<List<Marker>> showStateOnMarker(MapPosition position, MapController controller, dynamic profile, String token, String kategori) async {
    LatLngBounds? visibleBounds = controller.bounds;
    final List<Marker> marker = [];

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['RESTFUL_API']}/${profile['role'] == 'Pemilih' ? 'account' : 'pemilihan'}/find-state-in-bound?latSW=${visibleBounds!.southWest.latitude}&latNE=${visibleBounds.northEast.latitude}&lngSW=${visibleBounds.southWest.longitude}&lngNE=${visibleBounds.northEast.longitude}&kategori=$kategori'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);

      if (responseBody.isNotEmpty) {
        for (var i = 0; i < responseBody.length; i++) {
          double latitude = responseBody[i]['latitude'];
          double longitude = responseBody[i]['longitude'];
          String nama = responseBody[i]['nama'];
          int jumlah = responseBody[i]['data']['jumlah'];

          LatLng latLng = LatLng(latitude, longitude);

          if (visibleBounds.contains(latLng)) {
            marker.add(MarkerPerson(latitude, longitude, nama: nama, jumlah: jumlah));
          }
        }
      }
    }

    return marker;
  }
}
