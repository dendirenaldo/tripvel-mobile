import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';

class TujuhPenumpangScreen extends StatelessWidget {
  final int jumlahPenumpang;
  final List<dynamic> listTerisi;
  final double width;

  const TujuhPenumpangScreen({
    super.key,
    required this.jumlahPenumpang,
    required this.listTerisi,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: true);

    return Container(
      clipBehavior: Clip.hardEdge,
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                width: 50,
                height: 50,
                child: const Center(
                  child: Text('Supir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), textScaleFactor: 1.0),
                ),
              ),
              GestureDetector(
                onTap: () => listTerisi.contains('B') ? null : pemesananProvider.pilihKursi(context, 'B', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('B')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('B') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('B',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('B') || pemesananProvider.listKursi.contains('B') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
              GestureDetector(
                onTap: () => listTerisi.contains('E') ? null : pemesananProvider.pilihKursi(context, 'E', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('E')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('E') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('E',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('E') || pemesananProvider.listKursi.contains('E') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                width: 50,
                height: 50,
              ),
              GestureDetector(
                onTap: () => listTerisi.contains('C') ? null : pemesananProvider.pilihKursi(context, 'C', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('C')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('C') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('C',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('C') || pemesananProvider.listKursi.contains('C') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
              GestureDetector(
                onTap: () => listTerisi.contains('F') ? null : pemesananProvider.pilihKursi(context, 'F', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('F')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('F') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('F',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('F') || pemesananProvider.listKursi.contains('F') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => listTerisi.contains('A') ? null : pemesananProvider.pilihKursi(context, 'A', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('A')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('A') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('A',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('A') || pemesananProvider.listKursi.contains('A') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
              GestureDetector(
                onTap: () => listTerisi.contains('D') ? null : pemesananProvider.pilihKursi(context, 'D', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('D')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('D') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('D',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('D') || pemesananProvider.listKursi.contains('D') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
              GestureDetector(
                onTap: () => listTerisi.contains('G') ? null : pemesananProvider.pilihKursi(context, 'G', jumlahPenumpang),
                child: Container(
                  decoration: BoxDecoration(
                    color: listTerisi.contains('G')
                        ? Colors.green
                        : (pemesananProvider.listKursi.contains('G') ? const Color(0xFF2459A9) : Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Text('G',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: listTerisi.contains('G') || pemesananProvider.listKursi.contains('G') ? Colors.white : Colors.black),
                          textScaleFactor: 1.0)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
