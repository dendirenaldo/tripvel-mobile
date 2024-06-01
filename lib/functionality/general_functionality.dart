import 'package:intl/intl.dart';

class GeneralFunctionality {
  static String getBulanName(int bulan) {
    if (bulan == 1) {
      return 'Januari';
    } else if (bulan == 2) {
      return 'Februari';
    } else if (bulan == 3) {
      return 'Maret';
    } else if (bulan == 4) {
      return 'April';
    } else if (bulan == 5) {
      return 'Mei';
    } else if (bulan == 6) {
      return 'Juni';
    } else if (bulan == 7) {
      return 'Juli';
    } else if (bulan == 8) {
      return 'Agustus';
    } else if (bulan == 9) {
      return 'September';
    } else if (bulan == 10) {
      return 'Oktober';
    } else if (bulan == 11) {
      return 'November';
    } else if (bulan == 12) {
      return 'Desember';
    }
    return '';
  }

  static String getBulanNameSingkatan(int bulan) {
    if (bulan == 1) {
      return 'Jan';
    } else if (bulan == 2) {
      return 'Feb';
    } else if (bulan == 3) {
      return 'Mar';
    } else if (bulan == 4) {
      return 'Apr';
    } else if (bulan == 5) {
      return 'Mei';
    } else if (bulan == 6) {
      return 'Jun';
    } else if (bulan == 7) {
      return 'Jul';
    } else if (bulan == 8) {
      return 'Agus';
    } else if (bulan == 9) {
      return 'Sep';
    } else if (bulan == 10) {
      return 'Okt';
    } else if (bulan == 11) {
      return 'Nov';
    } else if (bulan == 12) {
      return 'Des';
    }
    return '';
  }

  static String tanggalIndonesiaPendek(String datetime, {bool tanpaTahun = false}) {
    final tanggal = datetime.substring(0, 10).split('-');
    String bulan = getBulanNameSingkatan(int.parse(tanggal[1]));
    return '${(int.parse(tanggal[2])).toString()} $bulan${tanpaTahun == false ? ' ${tanggal[0]}' : ''}';
  }

  static String tanggalIndonesia(String datetime, {bool tanpaTahun = false}) {
    final tanggal = datetime.substring(0, 10).split('-');
    String bulan = '';

    switch (int.parse(tanggal[1])) {
      case 0:
        bulan = 'Januari';
        break;
      case 1:
        bulan = 'Februari';
        break;
      case 2:
        bulan = 'Maret';
        break;
      case 3:
        bulan = 'April';
        break;
      case 4:
        bulan = 'Mei';
        break;
      case 5:
        bulan = 'Juni';
        break;
      case 6:
        bulan = 'Juli';
        break;
      case 7:
        bulan = 'Agustus';
        break;
      case 8:
        bulan = 'September';
        break;
      case 9:
        bulan = 'Oktober';
        break;
      case 10:
        bulan = 'November';
        break;
      case 11:
        bulan = 'Desember';
        break;
    }

    return '${(int.parse(tanggal[2])).toString()} $bulan${tanpaTahun == false ? ' ${tanggal[0]}' : ''}';
  }

  static String rupiah(int uang) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('id');
    return numberFormat.format(uang);
  }

  static String calculateTimeDifference(String time1, String time2) {
    DateTime dateTime1 = DateTime.parse("2023-06-05 $time1:00");
    DateTime dateTime2 = DateTime.parse("2023-06-05 $time2:00");
    Duration difference = dateTime2.difference(dateTime1);
    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;
    return "${hours}j ${minutes}m";
  }
}
