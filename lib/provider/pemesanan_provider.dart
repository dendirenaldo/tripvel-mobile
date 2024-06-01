import 'package:flutter/material.dart';

class PemesananProvider with ChangeNotifier {
  int? asalId;
  int? tujuanId;
  List<dynamic> listKursi = [];

  Future<void> set(String jenis, int nilai) async {
    if (jenis == 'Asal') {
      asalId = nilai;
    } else if (jenis == 'Tujuan') {
      tujuanId = nilai;
    }

    notifyListeners();
  }

  void pilihKursi(BuildContext context, String kursi, int jumlahPenumpang) {
    if (listKursi.contains(kursi)) {
      listKursi.remove(kursi);
    } else {
      if (listKursi.length < jumlahPenumpang) {
        listKursi.add(kursi);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Gagal"),
              content: const Text("Jumlah penumpang melebihi yang ingin kamu pilih"),
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

    notifyListeners();
  }
}
