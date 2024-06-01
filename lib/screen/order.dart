import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripvel/provider/auth_provider.dart';
import 'package:tripvel/screen/riwayat.dart';
import 'package:tripvel/screen/tiket.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F9),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TabBar(
            controller: tabController,
            labelColor: const Color(0xFF2459A9),
            unselectedLabelColor: Colors.black,
            indicatorColor: const Color(0xFF2459A9),
            tabs: const [
              Tab(text: 'Tiket'),
              Tab(text: 'Riwayat'),
            ],
          ),
          Flexible(
            fit: FlexFit.loose,
            child: TabBarView(
              controller: tabController,
              children: const [TiketScreen(), RiwayatScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
