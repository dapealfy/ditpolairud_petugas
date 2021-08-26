import 'dart:async';
import 'dart:convert';

import 'package:ditpolairud_petugas/pages/laporan/detail_laporan.dart';
import 'package:ditpolairud_petugas/pages/laporan/history_laporan.dart';
import 'package:ditpolairud_petugas/pages/laporan/tambah_laporan.dart';
import 'package:ditpolairud_petugas/widgets/laporan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;

class TabTwo extends StatefulWidget {
  @override
  _TabTwoState createState() => _TabTwoState();
}

class _TabTwoState extends State<TabTwo> with SingleTickerProviderStateMixin {
  TabController controller;
  final Location location = Location();
  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;

        _location = currentLocation;
      });
    });
  }

  //............
  // Laporan
  //............
  List laporan = [];
  Future<List> _dataLaporan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/list-laporan-user");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _laporan;

    _laporan = json.decode(response.body);
    setState(() {
      laporan = _laporan['report'];
      // print(prefs.getString('token').toString());
    });
  }

  //............
  // Tugas
  //............
  List tugas = [];
  Future<List> _dataTugas() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/list-laporan");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _tugas;

    _tugas = json.decode(response.body);
    setState(() {
      tugas = _tugas['report'];
    });
  }

  void initState() {
    controller = new TabController(vsync: this, length: 2);
    _dataLaporan();
    _dataTugas();
    _listenLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2.0,
        shadowColor: Colors.grey.withOpacity(0.2),
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          'Laporan',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryLaporan(),
                ),
              );
            },
            icon: Icon(TablerIcons.history),
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.black,
          controller: controller,
          tabs: <Widget>[
            Tab(
              text: "TUGAS",
            ),
            Tab(
              text: "ADUAN",
            ),
          ],
        ),
      ),
      body: TabBarView(controller: controller, children: <Widget>[
        RefreshIndicator(
          onRefresh: () async {
            _dataTugas();
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tugas == null ? 0 : tugas.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailLaporan(
                                  tugas[index]['complaint'], true),
                            ),
                          );
                        },
                        child: CardLaporan(tugas[index]['complaint']));
                  },
                ),
              ),
            ],
          ),
        ),
        RefreshIndicator(
          onRefresh: () async {
            _dataLaporan();
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: laporan == null ? 0 : laporan.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailLaporan(laporan[index], false),
                            ),
                          );
                        },
                        child: CardLaporan(laporan[index]));
                  },
                ),
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahLaporan(_location),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
