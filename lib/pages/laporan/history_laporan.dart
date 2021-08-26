import 'dart:async';
import 'dart:convert';

import 'package:ditpolairud_petugas/pages/laporan/detail_laporan.dart';
import 'package:ditpolairud_petugas/pages/laporan/tambah_laporan.dart';
import 'package:ditpolairud_petugas/widgets/laporan_card.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;

class HistoryLaporan extends StatefulWidget {
  @override
  _HistoryLaporanState createState() => _HistoryLaporanState();
}

class _HistoryLaporanState extends State<HistoryLaporan>
    with SingleTickerProviderStateMixin {
  TabController controller;

  //............
  // Laporan
  //............
  List laporan = [];
  Future<List> _dataLaporan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/history-laporan-user");
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
    Uri url = Uri.parse(setting.url_api + "api/history-laporan");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _tugas;

    _tugas = json.decode(response.body);
    setState(() {
      tugas = _tugas['report'];
      print(tugas);
    });
  }

  void initState() {
    controller = new TabController(vsync: this, length: 2);
    _dataLaporan();
    _dataTugas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        shadowColor: Colors.grey.withOpacity(0.2),
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          'Riwayat Laporan',
          style: TextStyle(color: Colors.black),
        ),
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
    );
  }
}
