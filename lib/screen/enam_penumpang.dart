import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/provider/pemesanan_provider.dart';

class EnamPenumpangScreen extends StatelessWidget {
  final int jumlahPenumpang;
  final List<dynamic> listTerisi;

  const EnamPenumpangScreen({
    super.key,
    required this.jumlahPenumpang,
    required this.listTerisi,
  });

  @override
  Widget build(BuildContext context) {
    final pemesananProvider = Provider.of<PemesananProvider>(context, listen: true);
    return Center(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/interior.webp',
              width: 330,
              // height: 30,
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
          ),
          Positioned(
            top: 100,
            left: 60,
            child: GestureDetector(
              onTap: () => listTerisi.contains('A') ? null : pemesananProvider.pilihKursi(context, 'A', jumlahPenumpang),
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      listTerisi.contains('A') ? Colors.green : (pemesananProvider.listKursi.contains('A') ? const Color(0xFF2459A9) : Colors.white),
                ),
                child: Center(
                    child: Text('A',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: listTerisi.contains('A') || pemesananProvider.listKursi.contains('A') ? Colors.white : Colors.black))),
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 150,
            child: GestureDetector(
              onTap: () => listTerisi.contains('B') ? null : pemesananProvider.pilihKursi(context, 'B', jumlahPenumpang),
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      listTerisi.contains('B') ? Colors.green : (pemesananProvider.listKursi.contains('B') ? const Color(0xFF2459A9) : Colors.white),
                ),
                child: Center(
                    child: Text('B',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: listTerisi.contains('B') || pemesananProvider.listKursi.contains('B') ? Colors.white : Colors.black))),
              ),
            ),
          ),
          Positioned(
            top: 75,
            left: 150,
            child: GestureDetector(
              onTap: () => listTerisi.contains('C') ? null : pemesananProvider.pilihKursi(context, 'C', jumlahPenumpang),
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      listTerisi.contains('C') ? Colors.green : (pemesananProvider.listKursi.contains('C') ? const Color(0xFF2459A9) : Colors.white),
                ),
                child: Center(
                    child: Text('C',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: listTerisi.contains('C') || pemesananProvider.listKursi.contains('C') ? Colors.white : Colors.black))),
              ),
            ),
          ),
          Positioned(
            top: 105,
            left: 150,
            child: GestureDetector(
              onTap: () => listTerisi.contains('D') ? null : pemesananProvider.pilihKursi(context, 'D', jumlahPenumpang),
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      listTerisi.contains('D') ? Colors.green : (pemesananProvider.listKursi.contains('D') ? const Color(0xFF2459A9) : Colors.white),
                ),
                child: Center(
                    child: Text('D',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: listTerisi.contains('D') || pemesananProvider.listKursi.contains('D') ? Colors.white : Colors.black))),
              ),
            ),
          ),
          Positioned(
            top: 55,
            left: 250,
            child: GestureDetector(
              onTap: () => listTerisi.contains('E') ? null : pemesananProvider.pilihKursi(context, 'E', jumlahPenumpang),
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      listTerisi.contains('E') ? Colors.green : (pemesananProvider.listKursi.contains('E') ? const Color(0xFF2459A9) : Colors.white),
                ),
                child: Center(
                    child: Text('E',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: listTerisi.contains('E') || pemesananProvider.listKursi.contains('E') ? Colors.white : Colors.black))),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 250,
            child: GestureDetector(
              onTap: () => listTerisi.contains('F') ? null : pemesananProvider.pilihKursi(context, 'F', jumlahPenumpang),
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:
                      listTerisi.contains('F') ? Colors.green : (pemesananProvider.listKursi.contains('F') ? const Color(0xFF2459A9) : Colors.white),
                ),
                child: Center(
                    child: Text('F',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: listTerisi.contains('F') || pemesananProvider.listKursi.contains('F') ? Colors.white : Colors.black))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
