import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/functionality/login_functionality.dart';
import 'package:tripvel/page/bantuan.dart';
import 'package:tripvel/page/login.dart';
import 'package:tripvel/page/ubah_password.dart';
import 'package:tripvel/page/ubah_profil.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final profile = authProvider.getAccount();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(50),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        '${dotenv.env['RESTFUL_API']}/account/foto-profil/${profile != null ? profile['gambar'] : 'default.png'}',
                        width: 75,
                        height: 75,
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
                    const SizedBox(width: 15),
                    SizedBox(
                      width: width - (60 + 75 + 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile != null ? profile['namaLengkap'] : 'Guest',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profile != null) const SizedBox(height: 10),
                          if (profile != null)
                            Text(
                              profile['role'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (profile != null) const Divider(thickness: 1),
              if (profile != null)
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(IconlyLight.call),
                          const SizedBox(width: 15),
                          Text('0${profile['nomorPonsel'].toString()}'),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.mail_outline_rounded),
                          const SizedBox(width: 15),
                          Text(profile['email']),
                        ],
                      ),
                    ],
                  ),
                ),
              const Divider(thickness: 1),
              // const SizedBox(height: 15),
              // Container(
              //   clipBehavior: Clip.hardEdge,
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     border: Border.all(color: const Color(0xB3E0DFDC), width: 1),
              //   ),
              //   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              //   child: IntrinsicHeight(
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceAround,
              //       children: [
              //         SizedBox(
              //           width: (width - 70) / 2,
              //           child: Column(
              //             children: const [
              //               Text('Rp1.000.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              //               SizedBox(height: 10),
              //               Text('Saldo'),
              //             ],
              //           ),
              //         ),
              //         const VerticalDivider(
              //           color: Color(0xB3E0DFDC),
              //           thickness: 1,
              //           width: 1,
              //         ),
              //         SizedBox(
              //           width: (width - 70) / 2,
              //           child: Column(
              //             children: const [
              //               Text('22', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              //               SizedBox(height: 10),
              //               Text('Booking'),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 15),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BantuanPage())),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(Icons.question_mark_outlined, size: 30, color: Color(0xFF2459A9)),
                          SizedBox(width: 15),
                          Text('Bantuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2459A9))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit_document, size: 30, color: Color(0xFF2459A9)),
                        SizedBox(width: 15),
                        Text('Syarat dan Ketentuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2459A9))),
                      ],
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () async => await launchUrl(
                        Uri.parse("https://wa.me/628998958830"),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(Icons.call_outlined, size: 30, color: Color(0xFF2459A9)),
                          SizedBox(width: 15),
                          Text('Hubungi Kami', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2459A9))),
                        ],
                      ),
                    ),
                    if (profile != null) const SizedBox(height: 30),
                    if (profile != null)
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UbahProfilPage())),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(Icons.settings_outlined, size: 30, color: Color(0xFF2459A9)),
                            SizedBox(width: 15),
                            Text('Ubah Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2459A9))),
                          ],
                        ),
                      ),
                    if (profile != null) const SizedBox(height: 30),
                    if (profile != null)
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UbahPasswordPage())),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(IconlyLight.lock, size: 30, color: Color(0xFF2459A9)),
                            SizedBox(width: 15),
                            Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2459A9))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (profile != null) {
                          LoginFunctionality.keluar(context, authProvider);
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(profile != null ? Icons.logout_outlined : Icons.login_outlined,
                              size: 30, color: profile != null ? Colors.red : const Color(0xFF2459A9)),
                          const SizedBox(width: 15),
                          Text(profile != null ? 'Keluar' : 'Masuk',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: profile != null ? Colors.red : const Color(0xFF2459A9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
