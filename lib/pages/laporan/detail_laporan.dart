import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditpolairud_petugas/pages/laporan/update_laporan.dart';
import 'package:ditpolairud_petugas/settings/formatter.dart';
import 'package:ditpolairud_petugas/widgets/view_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DetailLaporan extends StatefulWidget {
  final laporan;
  final bool update;
  DetailLaporan(this.laporan, this.update);
  @override
  _DetailLaporanState createState() => _DetailLaporanState();
}

class _DetailLaporanState extends State<DetailLaporan> {
  GoogleMapController _controller;
  static LatLng _kMapCenter;

  static CameraPosition _kInitialPosition;

  List<Marker> _markers = <Marker>[];

  updateLocationMap() {
    setState(() {
      _kMapCenter = LatLng(widget.laporan['lat'], widget.laporan['lng']);
      _kInitialPosition =
          CameraPosition(target: _kMapCenter, zoom: 15.0, tilt: 0, bearing: 0);
    });
  }

  void initState() {
    updateLocationMap();
    _dataProgress();
  }

  Widget _previewImages() {
    if (widget.laporan['complaint_documents'].toString() == '[]') {
      return Container();
    } else {
      return Container(
        height: 100,
        child: ListView.builder(
          itemCount: widget.laporan['complaint_documents'].length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              height: 100,
              width: 100,
              child: widget.laporan['complaint_documents'][index]['document']
                              .split(".")
                              .last ==
                          'jpeg' ||
                      widget.laporan['complaint_documents'][index]['document']
                              .split(".")
                              .last ==
                          'png'
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewPhoto(
                                widget.laporan['complaint_documents'][index]
                                    ['document']),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                          imageUrl: widget.laporan['complaint_documents'][index]
                              ['document'],
                          placeholder: (context, url) => Container(
                                width: 30,
                                height: 30,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          fit: BoxFit.cover),
                    )
                  : GestureDetector(
                      onTap: () async {
                        if (await canLaunch(
                            widget.laporan['complaint_documents'][index]
                                ['document'])) {
                          await launch(
                            widget.laporan['complaint_documents'][index]
                                ['document'],
                          );
                        } else {
                          throw 'Could not launch ' +
                              widget.laporan['complaint_documents'][index]
                                  ['document'];
                        }
                      },
                      child: Container(
                        color: Colors.black,
                        child: Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
            );
          },
        ),
      );
    }
  }

  //............
  // Progress
  //............
  List complaintProgress = [];
  Future<List> _dataProgress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api +
        "api/list-progres/" +
        widget.laporan['id'].toString());
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    });
    Map<String, dynamic> _complaintProgress;

    _complaintProgress = json.decode(response.body);
    setState(() {
      complaintProgress = _complaintProgress['complaint_progress'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _dataProgress();
        },
        child: Stack(
          children: [
            ListView(
              children: [
                Container(
                  height: 350,
                  child: GoogleMap(
                    initialCameraPosition: _kInitialPosition,
                    markers: Set<Marker>.of(_markers),
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _markers.add(
                          Marker(
                            markerId: MarkerId('231'),
                            position: LatLng(
                                widget.laporan['lat'], widget.laporan['lng']),
                            infoWindow: InfoWindow(
                                title: widget.laporan['description']),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Kode Aduan #' + widget.laporan['id'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Feather.user),
                              SizedBox(width: 10),
                              Text(widget.laporan['user']['name']),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Icon(Feather.calendar),
                              SizedBox(width: 10),
                              Text(
                                  waktuFormatter(widget.laporan['created_at'])),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      Text(
                        'Aduan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(widget.laporan['description']),
                      SizedBox(height: 20),
                      widget.laporan['complaint_documents'].toString() == '[]'
                          ? Container()
                          : Text(
                              'File Pendukung:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(height: 10),
                      _previewImages(),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 20),
                      Text(
                        'Update Progress:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: complaintProgress.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == 0
                                            ? Colors.blue.withOpacity(0.6)
                                            : Colors.white,
                                        border: Border.all(
                                            color: Colors.blue, width: 3),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              waktuFormatter(
                                                  complaintProgress[index]
                                                      ['created_at']),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 10),
                                            Text(complaintProgress[index]
                                                ['description']),
                                            SizedBox(height: 20),
                                            complaintProgress[index]
                                                        ['document'] ==
                                                    ''
                                                ? Container()
                                                : Container(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Dokumen: '),
                                                          SizedBox(height: 20),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              if (complaintProgress[index]
                                                                              [
                                                                              'document']
                                                                          .split(
                                                                              ".")
                                                                          .last ==
                                                                      'png' ||
                                                                  complaintProgress[index]
                                                                              [
                                                                              'document']
                                                                          .split(
                                                                              ".")
                                                                          .last ==
                                                                      'jpeg') {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        ViewPhoto(complaintProgress[index]
                                                                            [
                                                                            'document']),
                                                                    fullscreenDialog:
                                                                        true,
                                                                  ),
                                                                );
                                                              } else {
                                                                if (await canLaunch(
                                                                    complaintProgress[
                                                                            index]
                                                                        [
                                                                        'document'])) {
                                                                  await launch(
                                                                    complaintProgress[
                                                                            index]
                                                                        [
                                                                        'document'],
                                                                  );
                                                                } else {
                                                                  throw 'Could not launch ' +
                                                                      complaintProgress[
                                                                              index]
                                                                          [
                                                                          'document'];
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 200,
                                                              child: (complaintProgress[index]['document']
                                                                              .split(
                                                                                  ".")
                                                                              .last ==
                                                                          'png' ||
                                                                      complaintProgress[index]['document']
                                                                              .split(".")
                                                                              .last ==
                                                                          'jpeg')
                                                                  ? ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      child: CachedNetworkImage(
                                                                          imageUrl: complaintProgress[index]['document'],
                                                                          placeholder: (context, url) => Container(
                                                                                width: 30,
                                                                                height: 30,
                                                                                child: Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                ),
                                                                              ),
                                                                          fit: BoxFit.cover),
                                                                    )
                                                                  : Container(
                                                                      height:
                                                                          200,
                                                                      width:
                                                                          100,
                                                                      color: Colors
                                                                          .black,
                                                                      child: Icon(
                                                                          Icons
                                                                              .play_arrow,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                            ),
                                                          )
                                                        ]),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                              ],
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.keyboard_arrow_left),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.update == true
          ? FloatingActionButton(
              onPressed: () async {
                String result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateLaporan(widget.laporan['id'])),
                );
                setState(() {
                  if (result == "Done") {
                    _dataProgress();
                  }
                });
              },
              child: Icon(Icons.add),
            )
          : Container(),
    );
  }
}
