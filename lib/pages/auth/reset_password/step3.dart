import 'dart:async';
import 'dart:convert';

import 'package:ditpolairud_petugas/pages/auth/reset_password/step4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;

class StepThreeFP extends StatefulWidget {
  final otpCode;
  StepThreeFP(this.otpCode);
  @override
  _StepThreeFPState createState() => _StepThreeFPState();
}

class _StepThreeFPState extends State<StepThreeFP> {
  bool _obscureText = true;
  bool _condition = true;

  //Data stepThree
  Map<String, dynamic> datastepThree;

  //Function stepThree
  Future<List> _stepThree() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uri url = Uri.parse(setting.url_api + "api/cek-kode-otp");
    final response = await http.post(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + prefs.getString('token').toString()
    }, body: {
      "code": controllerOtp.text.toString(),
    });
    datastepThree = json.decode(response.body);
    if (datastepThree['status_code'] == 'RD-200') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StepFourFP(),
        ),
      );
    } else {
      setState(() {
        _condition = true;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("OTP tidak valid"),
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

  TextEditingController controllerOtp = TextEditingController();

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
                  "Verifikasi Email",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Text(
                      'Silahkan masukkan kode Verifikasi dari email anda.'),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: controllerOtp,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Feather.key),
                      border: InputBorder.none,
                      labelText: 'Kode Verifikasi',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _condition == true
                      ? () async {
                          Timer(Duration(seconds: 1),
                              () => setState(() => _condition = false));
                          await Future.delayed(Duration(milliseconds: 5000));
                          _stepThree();
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
                            'Verifikasi',
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
