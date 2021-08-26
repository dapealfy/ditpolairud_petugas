import 'dart:async';
import 'dart:io';

import 'package:ditpolairud_petugas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _obscureText = true;
  bool _condition = true;
  bool agree = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  //loading profile
  var loading_profile = false;

  SharedPref sharedPref = SharedPref();
  var dataUser;
  Future loadUser() async {
    var _dataUser = await sharedPref.read("dataUser");
    setState(() {
      dataUser = _dataUser;
      controllerNama.text = dataUser['name'];
      controllerNoTelp.text = dataUser['phone_number'];
      controllerEmail.text = dataUser['email'];
    });
  }

  // Ambil File

  var uploadPath;
  void _pilihGambar() async {
    try {
      var filePath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpeg', 'jpg', 'png'],
      );
      if (filePath == null) {
        return;
      }
      setState(() {
        this.uploadPath = filePath;
      });
    } on PlatformException catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }

  // upload avatar
  Future<List> _editProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Dio dio = new Dio();
    FormData formData;
    if (controllerPassword.text.length == 0) {
      if (uploadPath == null) {
        formData = new FormData.fromMap({
          'name': controllerNama.text.toString(),
          'email': controllerEmail.text.toString(),
          'phone_number': controllerNoTelp.text.toString(),
        });
      } else {
        formData = new FormData.fromMap({
          'name': controllerNama.text.toString(),
          'email': controllerEmail.text.toString(),
          'phone_number': controllerNoTelp.text.toString(),
          'avatar': await MultipartFile.fromFile(uploadPath.files.single.path),
        });
      }
    } else {
      if (uploadPath == null) {
        formData = new FormData.fromMap({
          'name': controllerNama.text.toString(),
          'email': controllerEmail.text.toString(),
          'phone_number': controllerNoTelp.text.toString(),
          'password': controllerPassword.text.toString(),
        });
      } else {
        formData = new FormData.fromMap({
          'name': controllerNama.text.toString(),
          'email': controllerEmail.text.toString(),
          'phone_number': controllerNoTelp.text.toString(),
          'password': controllerPassword.text.toString(),
          'avatar': await MultipartFile.fromFile(uploadPath.files.single.path),
        });
      }
    }
    var response = await dio.post(setting.url_api + "api/edit-profil",
        data: formData,
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ' + prefs.getString('token').toString()
        }, method: 'POST', responseType: ResponseType.json));
    if (response.data != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Berhasil Mengirim"),
            content: Container(child: Text('Berhasil mengubah data!')),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  sharedPref.save('dataUser', response.data['user']);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        loading_profile = false;
      });
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Gagal"),
            content: Container(child: Text('Pastikan data data sudah benar!')),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController controllerNama = TextEditingController();
  TextEditingController controllerNoTelp = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          _condition == false
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
      body: Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 20),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Center(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(100)),
                          height: 120,
                          width: 120,
                          child: dataUser == null
                              ? Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(),
                                )
                              : dataUser['avatar'] == null
                                  ? Center(
                                      child: Icon(LineAwesomeIcons.user,
                                          size: 50, color: Colors.white))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: uploadPath != null
                                          ? Image.file(
                                              File(
                                                  uploadPath.files.single.path),
                                              fit: BoxFit.contain)
                                          : Image.network(dataUser['avatar']),
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ButtonTheme(
                            minWidth: 50.0,
                            height: 50.0,
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(100.0)),
                              color: Colors.blue,
                              onPressed: () {
                                _pilihGambar();
                              },
                              child: Icon(Feather.camera,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: controllerNama,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Feather.user),
                        border: InputBorder.none,
                        labelText: 'Nama',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: controllerNoTelp,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Feather.phone),
                        border: InputBorder.none,
                        labelText: 'No Telepon',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        border: InputBorder.none,
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text('Hanya isi ketika ingin mengubah password'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            controller: controllerPassword,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              border: InputBorder.none,
                              labelText: 'Password',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                              horizontal: 17, vertical: 17),
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: _obscureText ? Colors.grey : Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          child: Icon(
                            _obscureText
                                ? LineAwesomeIcons.eye_slash
                                : LineAwesomeIcons.eye,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: _condition == true
                        ? () async {
                            if (_formKey.currentState.validate()) {
                              Timer(Duration(seconds: 1),
                                  () => setState(() => _condition = false));
                              await Future.delayed(
                                  Duration(milliseconds: 3000));
                              _editProfile();
                            }
                          }
                        : null,
                    child: AnimatedContainer(
                      padding: EdgeInsets.symmetric(vertical: 17),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                        color: _condition ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ubah Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
