import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;

class UpdateLaporan extends StatefulWidget {
  final id;
  UpdateLaporan(this.id);
  @override
  _UpdateLaporanState createState() => _UpdateLaporanState();
}

class _UpdateLaporanState extends State<UpdateLaporan> {
  TextEditingController titleController = TextEditingController();
  var loading_delik = false;

  Future<List> _sendLaporan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Dio dio = new Dio();
    FormData formData = new FormData.fromMap({
      'description': titleController.text,
      'document': await MultipartFile.fromFile(uploadPath.path),
    });
    var response = await dio.post(
        setting.url_api + "api/kirim-progres-laporan/" + widget.id.toString(),
        data: formData,
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ' + prefs.getString('token').toString()
        }));
    Map<String, dynamic> _laporan;

    _laporan = response.data;

    if (_laporan['status_code'] == 'RD-200') {
      Navigator.pop(context);
    } else {
      setState(() {
        loading_delik = false;
      });
    }
  }

  Widget _previewImages() {
    return Container(
      height: 70,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          height: 70,
          width: 70,
          child: Stack(
            children: [
              (uploadPath.path.split(".").last != 'mp4')
                  ? Image.file(File(uploadPath.path), fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      width: 100,
                      color: Colors.black,
                      child: Icon(Icons.play_arrow, color: Colors.white),
                    ),
              Positioned(
                top: 0,
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    print(uploadPath);
                    setState(() {
                      uploadPath = null;
                    });
                  },
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          )),
    );
    // return GridTile(child: Image.file(File(uploadPath), fit: BoxFit.contain));
  }

  String _filePath;
  var uploadPath;
  final ImagePicker _picker = ImagePicker();
  void getFilePath() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih"),
          content: Container(
              // height: 200,
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Feather.camera),
                onTap: () async {
                  try {
                    var filePath = await _picker.getImage(
                      source: ImageSource.camera,
                      imageQuality: 25,
                    );
                    if (filePath == null) {
                      return;
                    }
                    setState(() {
                      this.uploadPath = filePath;
                      Navigator.pop(context);
                    });
                  } on PlatformException catch (e) {
                    print("Error while picking the file: " + e.toString());
                  }
                },
                title: Text('Foto'),
              ),
              ListTile(
                leading: Icon(Icons.video_camera_back),
                onTap: () async {
                  try {
                    var filePath = await _picker.getVideo(
                      source: ImageSource.camera,
                    );
                    if (filePath == null) {
                      return;
                    }
                    setState(() {
                      this.uploadPath = filePath;
                      Navigator.pop(context);
                    });
                  } on PlatformException catch (e) {
                    print("Error while picking the file: " + e.toString());
                  }
                },
                title: Text('Video'),
              ),
            ],
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Progress Laporan',
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
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, "Done");
          return false;
        },
        child: Column(
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
                            Text('Isi Laporan'),
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
                              labelText: 'Ketik isi laporan progress anda...',
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
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: uploadPath == null
                                ? Column(
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
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: _previewImages(),
                                  ),
                          ),
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
                  if (titleController.text != '') {
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
      ),
    );
  }
}
