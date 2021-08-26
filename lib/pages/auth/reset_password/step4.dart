import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;

class StepFourFP extends StatefulWidget {
  @override
  _StepFourFPState createState() => _StepFourFPState();
}

class _StepFourFPState extends State<StepFourFP> {
  bool _obscureText = true;
  bool _condition = true;

  //Data stepFour
  Map<String, dynamic> datastepFour;

  //Function stepFour
  Future<List> _stepFour() async {
    if (controllerPassword.text == controllerPasswordConfirm.text) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Uri url = Uri.parse(setting.url_api + "api/ubah-password");
      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + prefs.getString('token').toString()
      }, body: {
        "password": controllerPassword.text.toString(),
      });
      datastepFour = json.decode(response.body);
      if (datastepFour['status_code'] == 'RD-200') {
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        setState(() {
          _condition = true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Server sedang down"),
                content: Container(child: Text('silahkan hubungi admin!')),
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Password tidak sama"),
            content: Container(child: Text('silahkan cek kembali data anda!')),
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

  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerPasswordConfirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
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
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buat Password Baru",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Text(
                      'Password baru anda harus berbeda dari password sebelumnya.'),
                ),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 17, vertical: 17),
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
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: controllerPasswordConfirm,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      border: InputBorder.none,
                      labelText: 'Konfirmasi Password',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _condition == true
                      ? () async {
                          Timer(Duration(seconds: 1),
                              () => setState(() => _condition = false));
                          await Future.delayed(Duration(milliseconds: 3000));
                          _stepFour();
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
                            'Reset Password',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
