import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;

class TambahLaporan extends StatefulWidget {
  final location;
  TambahLaporan(this.location);
  @override
  _TambahLaporanState createState() => _TambahLaporanState();
}

class _TambahLaporanState extends State<TambahLaporan> {
  TextEditingController titleController = TextEditingController();
  var loading_delik = false;

  // Ambil File
  String _filePath;
  List uploadPath = [];
  void getFilePath() async {
    try {
      var filePath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'png', 'mp4', 'mpeg', 'wav'],
      );
      if (filePath == null) {
        return;
      }
      setState(() {
        this.uploadPath.add(filePath);
      });
    } on PlatformException catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }

  Widget _previewImages() {
    if (uploadPath.toString() == '[]') {
      return Container();
    } else {
      return Container(
        height: 70,
        child: ListView.builder(
          itemCount: uploadPath.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                height: 70,
                width: 70,
                child: Stack(
                  children: [
                    Image.file(File(uploadPath[index].files.single.path),
                        fit: BoxFit.cover),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          print(uploadPath);
                          setState(() {
                            uploadPath.remove(uploadPath[index]);
                          });
                        },
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.close, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ));
          },
        ),
      );
      // return GridTile(child: Image.file(File(uploadPath), fit: BoxFit.contain));
    }
  }

  Future<List> _sendLaporan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Uri url = Uri.parse(setting.url_api + "api/kirim-aduan");
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    }, body: {
      'lat': widget.location.latitude.toString(),
      'lng': widget.location.longitude.toString(),
      'description': titleController.text,
    });
    Map<String, dynamic> _laporan;
    _laporan = json.decode(response.body);
    print(_laporan);
    if (_laporan['status_code'] == 'RD-200') {
      var i = 0;
      while (i < uploadPath.length) {
        Dio dio = new Dio();
        FormData formData = new FormData.fromMap({
          'document':
              await MultipartFile.fromFile(uploadPath[i].files.single.path),
        });
        var response = await dio.post(
            setting.url_api +
                "api/kirim-dokumen-aduan/" +
                _laporan['complaint']['id'].toString(),
            data: formData,
            options: Options(headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ' + prefs.getString('token').toString()
            }));
        Map<String, dynamic> __laporan;

        __laporan = response.data;
        print(__laporan);
        i++;
      }
      Navigator.pop(context);
    } else {
      setState(() {
        loading_delik = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kirim Laporan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          loading_delik == true
              ? MaterialButton(
                  onPressed: () {},
                  child: Container(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Laporan'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.2), width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: titleController,
                          keyboardType: TextInputType.text,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Ketik laporan anda...',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text('File Pendukung'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          getFilePath();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 40),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.2), width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Icon(
                                  Feather.upload,
                                  size: 50,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Upload file')
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: _previewImages(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                if (titleController.text != '' &&
                    uploadPath.toString() != '[]') {
                  if (loading_delik == false) {
                    setState(() {
                      loading_delik = true;
                    });
                    await Future.delayed(Duration(seconds: 3));
                    _sendLaporan();
                  }
                }
              },
              child: MediaQuery.of(context).viewInsets.bottom == 0
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            loading_delik == true ? Colors.grey : Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Kirim',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
