import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/page/login.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/screen/bank.dart';
import 'package:tripvel/screen/berita.dart';
import 'package:tripvel/screen/home.dart';
import 'package:tripvel/screen/jadwal.dart';
import 'package:tripvel/screen/kategori.dart';
import 'package:tripvel/screen/mobil.dart';
import 'package:tripvel/screen/order.dart';
import 'package:tripvel/screen/profile.dart';
import 'package:iconly/iconly.dart';
import 'package:tripvel/screen/travel.dart';
import 'package:tripvel/screen/tujuan.dart';
import 'package:tripvel/screen/user.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int currentPage;
  late PageController pageController;
  bool _isLoading = true;
  dynamic profile;

  void changePage(int index) {
    if (mounted) {
      setState(() {
        currentPage = index;
        pageController.jumpToPage(index);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    pageController = PageController(initialPage: currentPage);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        profile = authProvider.getAccount();
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget navBarItem(val) {
    return Expanded(
      child: Material(
        child: InkWell(
          onTap: val['onPress'] ?? () => changePage(val['index']),
          child: Ink(
            color: Colors.white,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        val[currentPage == val['index'] ? 'activeIcon' : 'icon'],
                        color: currentPage == val['index'] ? const Color(0xFF2459A9) : Colors.black,
                        size: 25,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        val['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: currentPage == val['index'] ? const Color(0xFF2459A9) : Colors.black,
                          fontWeight: currentPage == val['index'] ? FontWeight.bold : FontWeight.w400,
                        ),
                        textScaleFactor: 1.0,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (BuildContext context, AuthProvider authProvider, Widget? child) {
      List<Widget> pages = [];
      List<Map<String, dynamic>> navbarItems = [];
      var index = 0;
      final profiles = authProvider.profile;
      if (profiles == null || !(profiles != null && profiles['role'] == 'Supir')) {
        navbarItems.add({
          'icon': IconlyLight.home,
          'label': 'Home',
          'activeIcon': IconlyBold.home,
          'index': index++,
        });
        pages.add(const HomeScreen());
      }

      if (profiles != null) {
        if (profiles['role'] == 'Supir') {
          navbarItems.add({
            'icon': IconlyLight.bookmark,
            'label': 'Jadwal',
            'activeIcon': IconlyBold.bookmark,
            'index': index++,
          });
          pages.add(const JadwalScreen());
        } else {
          navbarItems.add({
            'icon': IconlyLight.buy,
            'label': 'Order',
            'activeIcon': IconlyBold.buy,
            'index': index++,
          });
          pages.add(const OrderScreen());
        }
      } else {
        navbarItems.add({
          'icon': IconlyLight.login,
          'label': 'Masuk',
          'activeIcon': IconlyBold.login,
          'index': index++,
          'onPress': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
        });
        pages.add(Container());
      }

      navbarItems.add({
        'icon': IconlyLight.profile,
        'label': 'Profil',
        'activeIcon': IconlyBold.profile,
        'index': index++,
      });
      pages.add(const ProfileScreen());

      return Stack(
        children: [
          if (!_isLoading)
            Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                constraints: const BoxConstraints(minHeight: double.infinity),
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages,
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: navbarItems.map((val) => navBarItem(val)).toList(),
                ),
              ),
            ),
          if (_isLoading)
            const Opacity(
              opacity: 0.2,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      );
    });
  }
}
