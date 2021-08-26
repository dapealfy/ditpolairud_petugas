import 'dart:async';
import 'dart:convert';

import 'package:ditpolairud_petugas/pages/auth/reset_password/step2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;

class StepOneFP extends StatefulWidget {
  @override
  _StepOneFPState createState() => _StepOneFPState();
}

class _StepOneFPState extends State<StepOneFP> {
  bool _condition = true;

  TextEditingController controllerEmail = TextEditingController();

  //Data StepOne
  Map<String, dynamic> datastepOne;

  //Function StepOne
  Future<List> _stepOne() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/kirim-email");
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
    }, body: {
      "email": controllerEmail.text.toString(),
    });
    datastepOne = json.decode(response.body);
    if (datastepOne['status_code'] == 'RD-200') {
      setState(() {
        prefs.setString('token', datastepOne['token'].toString());
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StepTwoFP(datastepOne['otp_code']['code']),
        ),
      );
    } else {
      setState(() {
        _condition = true;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Email tidak ditemukan"),
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
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Text(
                      'Masukkan alamat email yang terhubung dengan akun anda dan kami akan mengirimkan email dengan instruksi untuk me-reset password anda.'),
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
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _condition == true
                      ? () async {
                          Timer(Duration(seconds: 1),
                              () => setState(() => _condition = false));
                          await Future.delayed(Duration(milliseconds: 3000));
                          _stepOne();
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
                            'Kirim Instruksi',
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
