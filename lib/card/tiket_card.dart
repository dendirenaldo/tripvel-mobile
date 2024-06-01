import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/component/button_component.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/page/titik_jemput.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';

class TiketCard extends StatelessWidget {
  final double width;
  final double height;
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
  final bool? isOrder;

  const TiketCard({
    super.key,
    required this.width,
    required this.height,
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
    this.isOrder,
  });

  void pilih(BuildContext context) {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: false);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Travel',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                          Flexible(
                            child: Text(
                              travel,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tanggal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Flexible(
                            child: Text(
                              tanggal,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Asal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                          Flexible(
                            child: Text(
                              '$asalLengkap ($jamBerangkat)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tujuan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                          Flexible(
                            child: Text(
                              '$tujuanLengkap ($jamTiba)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                          Flexible(
                            child: Text(
                              'IDR ${GeneralFunctionality.rupiah(harga)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jumlah Penumpang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                          Flexible(
                            child: Text(
                              '$jumlahPenumpang Penumpang',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textScaleFactor: 1.0,
                          ),
                          Flexible(
                            child: Text(
                              'IDR ${GeneralFunctionality.rupiah(harga * jumlahPenumpang)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ButtonComponent(
                        label: 'Pilih & Bayar',
                        onClick: () {
                          pemesananProvider.listKursi = [];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TitikJemputPage(
                                id: id,
                                travelId: travelId,
                                travel: travel,
                                tanggal: tanggal,
                                asalLengkap: asalLengkap,
                                asalSingkatan: asalSingkatan,
                                tujuanLengkap: tujuanLengkap,
                                tujuanSingkatan: tujuanSingkatan,
                                jamBerangkat: jamBerangkat,
                                jamTiba: jamTiba,
                                jumlahPenumpang: jumlahPenumpang,
                                harga: harga,
                              ),
                            ),
                          );
                        },
                      )
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
                  child: const Divider(thickness: 6),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          if (isOrder == null) pilih(context);
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(50),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      '${dotenv.env['RESTFUL_API']}/travel/gambar/$travelId',
                      width: 30,
                      height: 30,
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
                            textScaleFactor: 1.0,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    travel,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textScaleFactor: 1.0,
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jamBerangkat,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            textScaleFactor: 1.0,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            asalSingkatan,
                            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            GeneralFunctionality.calculateTimeDifference(jamBerangkat, jamTiba),
                            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                            textScaleFactor: 1.0,
                          ),
                          const SizedBox(
                            width: 60,
                            child: Divider(
                              thickness: 2,
                              color: Colors.red,
                            ),
                          ),
                          const Text(
                            'ditempat',
                            style: TextStyle(fontSize: 12.5, color: Colors.black54),
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jamTiba,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            textScaleFactor: 1.0,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tujuanSingkatan,
                            style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                            textScaleFactor: 1.0,
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'IDR ${GeneralFunctionality.rupiah(harga)}',
                        style: const TextStyle(color: Color(0xFF2459A9), fontWeight: FontWeight.w700),
                        textScaleFactor: 1.0,
                      ),
                      const Text(
                        '/pax',
                        style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w400),
                        textScaleFactor: 1.0,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
