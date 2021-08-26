import 'dart:async';
import 'dart:convert';

import 'package:ditpolairud_petugas/pages/kapal/detail_kapal.dart';
import 'package:ditpolairud_petugas/pages/laporan/detail_laporan.dart';
import 'package:ditpolairud_petugas/pages/laporan/history_laporan.dart';
import 'package:ditpolairud_petugas/widgets/videocall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;

class TabOne extends StatefulWidget {
  @override
  _TabOneState createState() => _TabOneState();
}

class _TabOneState extends State<TabOne> {
  GoogleMapController _controller;
  static final LatLng _kMapCenter = LatLng(-1.2605708, 116.8057993);

  final Location location = Location();

  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;
  final Set<Polyline> _polyline = {};
  final controller = Completer<GoogleMapController>();

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

  static final CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 13.0, tilt: 0, bearing: 0);

  List<Marker> markers = <Marker>[];
  List<Marker> markersTugas = <Marker>[];

  BitmapDescriptor pinLocationIcon;
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/ship.png');
  }

  var pilih_kapal = '';

  void initState() {
    setCustomMapPin();
    _listenLocation();
    // datakapal(0);
    _datalistPilihKapal();
    // _dataTugas();
    updateMarker();
    _datalistKategoriKapal();
    _datalistSubCategoryKapal();
    _callStatus();
  }

  pilihKapal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pilih_kapal = prefs.getString('pilih_kapal') ?? '';
    });
  }

  //............
  // List Kapal
  //............

  List listKapal = [];
  Future<List> datakapal(data) async {
    if (data == []) {
      data = 0;
    }
    // print(filter);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/list-filter-kapal-map");
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    }, body: {
      'sub_ship_category_id':
          data.toString().replaceAll('[', '').replaceAll(']', ''),
    });
    Map<String, dynamic> _listKapal;

    _listKapal = json.decode(response.body);
    setState(() {
      listKapal = _listKapal['ship'];
      // print(listKapal);
      var i = 0;
      while (i < listKapal.length) {
        var id = listKapal[i]['id'];
        var lat = listKapal[i]['lat'].toString();
        var lng = listKapal[i]['lng'].toString();
        var ais = listKapal[i]['role'].toString() == 'ais' ? true : false;
        setState(() {
          markers.add(
            Marker(
              rotation: double.parse(listKapal[i]['heading'] ?? '0'),
              markerId: MarkerId(listKapal[i]['id'].toString()),
              position: LatLng(listKapal[i]['lat'], listKapal[i]['lng']),
              icon: pinLocationIcon,
              infoWindow: InfoWindow(
                  title: listKapal[i]['name_of_goods_bmn'] ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailKapal(id, ais: ais, lat: lat, lng: lng),
                      ),
                    );
                  }),
            ),
          );
        });
        i++;
      }
    });
  }

  List listKategoriKapal = [];
  Future<List> _datalistKategoriKapal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/kategori");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _listKategoriKapal;

    _listKategoriKapal = json.decode(response.body);
    setState(() {
      listKategoriKapal = _listKategoriKapal['category'];
    });
  }

  //............
  // List Kapal
  //............
  List listPilihKapal = [];
  Future<List> _datalistPilihKapal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/list-kapal-petugas");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _listPilihKapal;

    _listPilihKapal = json.decode(response.body);
    setState(() {
      listPilihKapal = _listPilihKapal['ship'];
    });
  }

  List listSubCategoryKapal = [];
  Future<List> _datalistSubCategoryKapal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/sub-kategori");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _listSubCategoryKapal;

    _listSubCategoryKapal = json.decode(response.body);
    setState(() {
      listSubCategoryKapal = _listSubCategoryKapal['sub_category'];
    });
  }

  //Pilih Kapal
  void _kirimPilihKapal(id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/pilih-kapal");
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    }, body: {
      'ship_id': id.toString(),
    });
    print(response.body);
  }

  int call_status = 0;
  var nameScreen = '';
  Future<List> _callStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/call-status");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _call_status;

    _call_status = json.decode(response.body);

    setState(() {
      call_status = _call_status['user']['call_status'];
      print(call_status);
    });
    if (call_status != 0) {
      if (prefs.getString('statusPush').toString() == '0') {
        String result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                JoinChannelVideo(call_status, _call_status['token']),
          ),
        );
        setState(() {
          this.nameScreen = result;
          print(result);
          if (result == "Done") {
            call_status = 0;
            _callStatus();
          }
        });

        prefs.setString('statusPush', '1');
      }
    }
    if (call_status == 0) {
      Future.delayed(Duration(seconds: 2), () {
        _callStatus();
      });
    }
  }

  void _currentLocation() async {
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }

  updateMarker() {
    markers.clear();
    _dataTugas();
    datakapal(filter);
    Future.delayed(Duration(seconds: 80), () {
      updateMarker();
    });
  }

  //............
  // Tugas
  //............
  List tugas = [];
  Future<List> _dataTugas() async {
    _polyline.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/list-laporan");
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _tugas;

    _tugas = json.decode(response.body);
    setState(() {
      tugas = _tugas['report'] ?? [];
      var i = 0;
      while (i < tugas.length) {
        setState(() {
          List<LatLng> latlng = [
            LatLng(_location.latitude, _location.longitude),
            LatLng(tugas[i]['complaint']['lat'], tugas[i]['complaint']['lng']),
          ];
          var data = tugas[i]['complaint'];
          var idMarker = tugas[i]['id'];
          markers.add(
            Marker(
              markerId: MarkerId('complaint' + i.toString()),
              position: LatLng(
                  tugas[i]['complaint']['lat'], tugas[i]['complaint']['lng']),
              infoWindow: InfoWindow(
                title: tugas[i]['complaint']['description'].toString(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailLaporan(data, true),
                    ),
                  );
                },
              ),
            ),
          );
          _polyline.add(Polyline(
            polylineId: PolylineId('poly' + tugas[i]['id'].toString()),
            visible: true,
            points: latlng,
            color: Colors.red,
            width: 2,
          ));
        });
        i++;
      }
    });
  }

  var filter = [];

  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                transform: Matrix4.translationValues(0, 0, 0),
                height: 145,
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder: (_, setState) {
                                  return Dialog(
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(
                                              'Filter Kategori:',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              child: ListView.builder(
                                                itemCount:
                                                    listKategoriKapal.length ??
                                                        0,
                                                itemBuilder: (context, i) {
                                                  return Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(height: 20),
                                                        Text(
                                                          listKategoriKapal[i]
                                                              ['title'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        SizedBox(height: 10),
                                                        ListView.builder(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount: listKategoriKapal[
                                                                            i][
                                                                        'sub_ship_categories']
                                                                    .length ??
                                                                0,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              var filterSementara =
                                                                  listKategoriKapal[
                                                                          i][
                                                                      'sub_ship_categories'];
                                                              return InkWell(
                                                                onTap: () {
                                                                  if (filter.contains(
                                                                          filterSementara[index]
                                                                              [
                                                                              'id']) !=
                                                                      true) {
                                                                    filter.add(filterSementara[
                                                                            index]
                                                                        ['id']);
                                                                    setState(
                                                                        () {});
                                                                  } else {
                                                                    filter.remove(
                                                                        filterSementara[index]
                                                                            [
                                                                            'id']);
                                                                    setState(
                                                                        () {});
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              7),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            32,
                                                                        width:
                                                                            32,
                                                                        child:
                                                                            Checkbox(
                                                                          value:
                                                                              filter.contains(filterSementara[index]['id']),
                                                                          onChanged:
                                                                              (value) {
                                                                            if (filter.contains(filterSementara[index]['id']) !=
                                                                                true) {
                                                                              filter.add(filterSementara[index]['id']);
                                                                              setState(() {});
                                                                            } else {
                                                                              filter.remove(filterSementara[index]['id']);
                                                                              setState(() {});
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                      Text(listKategoriKapal[i]['sub_ship_categories']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'title'])
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    filter.clear();
                                                  });
                                                  markers.clear();
                                                  _dataTugas();
                                                  datakapal(filter);
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                  child: Text(
                                                    'Bersihkan',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  markers.clear();
                                                  _dataTugas();
                                                  datakapal(filter);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                  child: Text(
                                                    'Terapkan',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                          icon: Icon(Feather.menu, color: Colors.white),
                        ),
                        Text(
                          'DITPOLAIRUD PETUGAS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            markers.clear();
                            _dataTugas();
                            datakapal(filter);
                          },
                          icon: Icon(TablerIcons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GoogleMap(
                  mapToolbarEnabled: false,
                  initialCameraPosition: _kInitialPosition,
                  polylines: _polyline,
                  markers: Set<Marker>.of(markers),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  rotateGesturesEnabled: false,
                  onMapCreated: (GoogleMapController controllera) async {
                    _controller = controllera;
                    controller.complete(controllera);
                    location.onLocationChanged.listen((l) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Uri url = Uri.parse(setting.url_api + "api/kirim-lokasi");
                      final response = await http.post(url, headers: {
                        'Accept': 'application/json',
                        'Authorization':
                            'Bearer ' + prefs.getString('token').toString()
                      }, body: {
                        'lat': l.latitude.toString(),
                        'lng': l.longitude.toString(),
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              // onTap: _currentLocation,
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                print(prefs.getString('fcm_token'));
              },
              child: Container(
                height: 50,
                width: 50,
                decoration:
                    BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: Icon(Icons.location_searching, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      0.0,
                    ),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          pilihKapal();
                          return SimpleDialog(
                            title: const Text('Pilih Kapal'),
                            children: <Widget>[
                              RadioListTile(
                                value: '',
                                groupValue: pilih_kapal,
                                onChanged: (value_pilih_kapal) async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString(
                                      'pilih_kapal', value_pilih_kapal);
                                  setState(() {
                                    pilih_kapal = value_pilih_kapal;
                                    Navigator.pop(context);
                                    _kirimPilihKapal('');
                                  });
                                },
                                title: Text('KELUAR KAPAL'),
                              ),
                              Divider(),
                              Container(
                                width: double.maxFinite,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: listPilihKapal == null
                                        ? 0
                                        : listPilihKapal.length,
                                    itemBuilder: (context, index) {
                                      return RadioListTile(
                                        value: listPilihKapal[index]
                                            ['name_of_goods_bmn'],
                                        groupValue: pilih_kapal,
                                        onChanged: (value_pilih_kapal) async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.setString(
                                              'pilih_kapal', value_pilih_kapal);
                                          setState(() {
                                            pilih_kapal = value_pilih_kapal;
                                            Navigator.pop(context);
                                          });
                                          _kirimPilihKapal(
                                              listPilihKapal[index]['id']);
                                        },
                                        title: Text(listPilihKapal[index]
                                            ['name_of_goods_bmn']),
                                      );
                                    }),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      pilih_kapal == ''
                          ? Text(
                              'Pilih kapal anda...',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Anda sedang berada di kapal',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  pilih_kapal.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              ],
                            ),
                      Icon(
                        TablerIcons.ship,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
