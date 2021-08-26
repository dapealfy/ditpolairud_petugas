import 'dart:async';
import 'dart:convert';

import 'package:ditpolairud_petugas/main.dart';
import 'package:ditpolairud_petugas/pages/auth/reset_password/step1.dart';
import 'package:ditpolairud_petugas/pages/tabs/home_page.dart';
import 'package:ditpolairud_petugas/settings/token_monitor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String msg = '';
  bool _obscureText = true;
  bool _condition = true;

  @override
  void initState() {
    super.initState();
  }

  SharedPref sharedPref = SharedPref();

  final _formKey = GlobalKey<FormState>();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  String token = '';

  //Data Login
  Map<String, dynamic> datalogin;

  //Function Login
  Future<List> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var fcm_token = await FirebaseMessaging.instance.getToken();
    Uri url = Uri.parse(setting.url_api + "api/login-petugas");
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
    }, body: {
      "email": controllerEmail.text.toString(),
      "password": controllerPassword.text.toString(),
      "fcm_token": fcm_token ?? 'null',
    });
    datalogin = json.decode(response.body);
    if (datalogin['status_code'] == 'RD-200') {
      if (datalogin['user']['verified'] == 1) {
        setState(() {
          prefs.setString('token', datalogin['token'].toString());
          prefs.setString('isLoggedIn', 'true');
          sharedPref.save('dataUser', datalogin['user']);
        });

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        setState(() {
          _condition = true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Login gagal"),
                content: Container(
                    child: Text(
                        'Data anda belum terverifikasi oleh admin, coba lagi nanti!')),
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
        });
      }
    } else {
      setState(() {
        _condition = true;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Login gagal"),
              content: Container(
                  child: Text(
                      'Cek kembali data anda, jika masalah berlanjut hubungi admin!')),
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
      });
    }
  }

  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: 'Tekan sekali lagi untuk keluar',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey.withOpacity(0.1),
          textColor: Colors.white,
          fontSize: 16.0);
      return Future.value(false);
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          margin: EdgeInsets.only(left: 30, right: 30, top: 20),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                TokenMonitor((token) {
                  this.token = token;
                  return Container();
                }),
                ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 150,
                      ),
                    ),
                    SizedBox(height: 60),
                    Text(
                      "Selamat Datang!",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('E-INFOLAP DITPOLAIRUD POLDA KALTIM PETUGAS'),
                    SizedBox(height: 40),
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
                    SizedBox(height: 20),
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
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: _condition == true
                          ? () async {
                              if (_formKey.currentState.validate()) {
                                Timer(Duration(seconds: 1),
                                    () => setState(() => _condition = false));
                                await Future.delayed(
                                    Duration(milliseconds: 3000));
                                _login();
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
                                'Login',
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
                    SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StepOneFP(),
                            ),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
