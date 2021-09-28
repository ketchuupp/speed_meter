import 'package:flutter/material.dart';
import 'package:speedomotor/detailsPage.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'dart:async';
import 'dashboardPage.dart';
import 'connect.dart';
// import 'package:flutter/services.dart';
// import 'connectionPage.dart';

void main() => runApp(MaterialApp(
      home: SafeArea(child: const MyTabbedPage()),
    ));

class MyTabbedPage extends StatefulWidget {
  const MyTabbedPage({Key? key}) : super(key: key);
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage>
    with SingleTickerProviderStateMixin {
  static List<Container> myTabs = <Container>[
    Container(height: 100.0, child: const Tab(text: 'DASHBOARD')),
    Container(child: const Tab(text: 'CONNECTION')),
    Container(child: const Tab(text: 'DETAILS')),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[900],
      appBar: TabBar(
        controller: _tabController,
        tabs: myTabs,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DashboardPage(),
          // ConnectionPage(),
          BluetoothApp(),
          DetailsPage(),
        ],
      ),
    );
  }
}
