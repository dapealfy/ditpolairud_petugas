import 'package:ditpolairud_petugas/main.dart';
import 'package:ditpolairud_petugas/pages/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ditpolairud_petugas/settings/url_api.dart' as setting;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TabThree extends StatefulWidget {
  @override
  _TabThreeState createState() => _TabThreeState();
}

class _TabThreeState extends State<TabThree> {
  SharedPref sharedPref = SharedPref();
  var dataUser;
  Future loadUser() async {
    var _dataUser = await sharedPref.read("dataUser");
    setState(() {
      dataUser = _dataUser;
    });
  }

  void initState() {
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: false,
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Feather.help_circle,
                color: Colors.black.withOpacity(0.7),
              ),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            loadUser();
          },
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                print(dataUser);
                              },
                              child: Container(
                                height: 70,
                                width: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(dataUser['avatar'],
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat datang',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  dataUser['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Logout"),
                              content:
                                  Container(child: Text('Apakah anda yakin?')),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    "Batal",
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Ya"),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: Container(
                                            padding: EdgeInsets.all(25),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Text("Mohon Tunggu..."),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    prefs.setString('isLoggedIn', "false");
                                    Uri url = Uri.parse(
                                        setting.url_api + "api/logout");
                                    final response =
                                        await http.post(url, headers: {
                                      'Accept': 'application/json',
                                      'Authorization': 'Bearer ' +
                                          prefs.getString('token').toString()
                                    });
                                    new Future.delayed(new Duration(seconds: 2),
                                        () {
                                      Navigator.pushReplacementNamed(
                                          context, "/login");
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: ListTile.divideTiles(context: context, tiles: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Icon(Feather.user),
                        title: Text('Profile'),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (await canLaunch(
                            'https://ditpolairud-2021.inotive.id/terms-condition')) {
                          await launch(
                            'https://ditpolairud-2021.inotive.id/terms-condition',
                            forceWebView: true,
                            enableJavaScript: true,
                            enableDomStorage: true,
                          );
                        } else {
                          throw 'Could not launch ' +
                              'https://ditpolairud-2021.inotive.id/terms-condition';
                        }
                      },
                      child: ListTile(
                        leading: Icon(Feather.book),
                        title: Text('Ketentuan Layanan'),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (await canLaunch(
                            'https://ditpolairud-2021.inotive.id/privacy-policy')) {
                          await launch(
                            'https://ditpolairud-2021.inotive.id/privacy-policy',
                            forceWebView: true,
                            enableJavaScript: true,
                            enableDomStorage: true,
                          );
                        } else {
                          throw 'Could not launch ' +
                              'https://ditpolairud-2021.inotive.id/privacy-policy';
                        }
                      },
                      child: ListTile(
                        leading: Icon(Feather.shield_off),
                        title: Text('Kebijakan Privasi'),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ]).toList(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      'Laporkan Kendala Aplikasi',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Icon(
                          Icons.headset_mic_outlined,
                          color: Colors.blue.withOpacity(0.8),
                          size: 50,
                        ),
                        SizedBox(width: 10),
                        Container(
                          child: Text(
                            'Hai, Butuh bantuan?',
                            style: TextStyle(
                                color: Colors.blue.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
