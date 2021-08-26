import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailKapal extends StatefulWidget {
  final int idKapal;
  final lat;
  final lng;
  final ais;
  DetailKapal(this.idKapal, {this.ais, this.lat, this.lng});
  @override
  _DetailKapalState createState() => _DetailKapalState();
}

class _DetailKapalState extends State<DetailKapal> {
  List datakapal = [];
  Future<List> _datakapal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(
        setting.url_api + "api/detail-kapal-map/" + widget.idKapal.toString());
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _datakapal;

    _datakapal = json.decode(response.body);
    setState(() {
      datakapal = _datakapal['ship'];
    });
  }

  updateLocationMap() {
    setState(() {
      _kMapCenter = LatLng(double.parse(widget.lat), double.parse(widget.lng));
      _kInitialPosition =
          CameraPosition(target: _kMapCenter, zoom: 13.0, tilt: 0, bearing: 0);
    });
  }

  void initState() {
    _datakapal();
    updateLocationMap();
    super.initState();
  }

  GoogleMapController _controller;
  static LatLng _kMapCenter;

  static CameraPosition _kInitialPosition;

  List<Marker> _markers = <Marker>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: datakapal.toString() == '[]'
          ? Center(
              child: Container(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ))
          : widget.ais == false
              ? SafeArea(
                  child: Stack(
                    children: [
                      ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 90),
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: CachedNetworkImage(
                                    imageUrl: datakapal[0]['image'].toString(),
                                    placeholder: (context, url) => Container(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(height: 20),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kondisi',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      'BB: ' +
                                          datakapal[0]['bb'].toString() +
                                          ' | RR: ' +
                                          datakapal[0]['rr'].toString() +
                                          ' | RB: ' +
                                          datakapal[0]['rb'].toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Keterangan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['description'].toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Nomor Telpon',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['user'] == null
                                          ? '-'
                                          : datakapal[0]['user']['phone_number']
                                              .toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Kapten Kapal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['user'] == null
                                          ? 'Tidak ada'
                                          : (datakapal[0]['user']['name']
                                                  .toString() +
                                              ' | ' +
                                              datakapal[0]['user']['position']
                                                  .toString()),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Kecepatan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['speed'].toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Kapasitas',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['capacity'].toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Posisi Kapal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 200,
                                      child: GoogleMap(
                                        initialCameraPosition:
                                            _kInitialPosition,
                                        markers: Set<Marker>.of(_markers),
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          setState(() {
                                            _markers.add(
                                              Marker(
                                                markerId: MarkerId('231'),
                                                position: LatLng(
                                                    datakapal[0]['lat'],
                                                    datakapal[0]['lng']),
                                              ),
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          color: Colors.lightBlue,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'ID',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        ' | ' +
                                            datakapal[0]['name_of_goods_bmn']
                                                .toString() +
                                            ' ',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      Text(
                                        '(' +
                                            datakapal[0]['type'].toString() +
                                            ')',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    datakapal[0]['sub_ship_category']['title']
                                            .toString() +
                                        ' | ' +
                                        datakapal[0]['merk'].toString() +
                                        ' | ' +
                                        datakapal[0]['merk_type'].toString() +
                                        ' | ' +
                                        datakapal[0]['production_year']
                                            .toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Stack(
                    children: [
                      ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 90),
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: CachedNetworkImage(
                                    imageUrl: datakapal[0]['image'].toString(),
                                    placeholder: (context, url) => Container(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(height: 20),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kecepatan Kapal / Arah Kapal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']['speed']
                                              .toString() +
                                          'kts / ' +
                                          datakapal[0]['heading'].toString() +
                                          '°',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Luas Kapal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']['length']
                                              .toString() +
                                          'M / ' +
                                          datakapal[0]['ship_particular']
                                                  ['width']
                                              .toString() +
                                          'M',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Kapasitas Kapal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']['dwt']
                                              .toString() +
                                          ' ton',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Berat Muatan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']['grt']
                                              .toString() +
                                          ' ton',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Tujuan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']
                                              ['destination']
                                          .toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Owner',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']['owner']
                                          .toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Manager',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      datakapal[0]['ship_particular']['manager']
                                          .toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Posisi Kapal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 200,
                                      child: GoogleMap(
                                        initialCameraPosition:
                                            _kInitialPosition,
                                        markers: Set<Marker>.of(_markers),
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          setState(() {
                                            _markers.add(
                                              Marker(
                                                markerId: MarkerId('231'),
                                                position: LatLng(
                                                    datakapal[0]['lat'],
                                                    datakapal[0]['lng']),
                                              ),
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          color: Colors.lightBlue,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: RichText(
                                          maxLines: 1,
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: datakapal[0]
                                                          ['ship_particular']
                                                      ['flag']
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                            TextSpan(
                                              text: ' | ' +
                                                  datakapal[0]
                                                          ['name_of_goods_bmn']
                                                      .toString() +
                                                  ' ',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            TextSpan(
                                              text: '(' +
                                                  datakapal[0][
                                                              'ship_particular']
                                                          ['type_name']
                                                      .toString() +
                                                  ')',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    datakapal[0]['sub_ship_category']['title']
                                            .toString() +
                                        ' ' +
                                        datakapal[0]['ship_particular']
                                                ['year_built']
                                            .toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
