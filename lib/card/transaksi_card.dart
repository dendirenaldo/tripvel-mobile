import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tripvel/functionality/general_functionality.dart';
import 'package:tripvel/page/info_transaksi.dart';

class TransaksiCard extends StatelessWidget {
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
  final String statusPembayaran;
  final int jumlahPenumpang;
  final int harga;

  const TransaksiCard({
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
    required this.statusPembayaran,
    required this.jumlahPenumpang,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InfoTransaksiPage(id: id))),
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
                      width: 65,
                      height: 65,
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
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(travel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(GeneralFunctionality.tanggalIndonesia(tanggal),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black54))
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jamBerangkat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(asalSingkatan, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(GeneralFunctionality.calculateTimeDifference(jamBerangkat, jamTiba),
                              style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                          const SizedBox(
                            width: 60,
                            child: Divider(
                              thickness: 2,
                              color: Colors.red,
                            ),
                          ),
                          const Text('ditempat', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jamTiba, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(tujuanSingkatan, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('IDR ${GeneralFunctionality.rupiah(harga)}',
                          style: const TextStyle(color: Color(0xFF2459A9), fontWeight: FontWeight.w700)),
                      Text(statusPembayaran,
                          style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
