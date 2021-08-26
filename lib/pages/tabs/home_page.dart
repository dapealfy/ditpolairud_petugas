import 'package:ditpolairud_petugas/pages/tabs/tab1.dart';
import 'package:ditpolairud_petugas/pages/tabs/tab2.dart';
import 'package:ditpolairud_petugas/pages/tabs/tab3.dart';
import 'package:ditpolairud_petugas/settings/token_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String token = '';
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFEEEEEE),
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: currentPage,
                  children: [
                    TabOne(),
                    TabTwo(),
                    TabThree(),
                  ],
                ),
              ),

              //BOTTOM NAVBAR
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                      offset: Offset(
                        0.0,
                        0.0,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          currentPage = 0;
                        });
                      },
                      child: ItemNavbar(currentPage == 0 ? true : false,
                          icon: Feather.home, itemName: 'Home'),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          currentPage = 1;
                        });
                      },
                      child: ItemNavbar(currentPage == 1 ? true : false,
                          icon: Feather.edit, itemName: 'Laporan'),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          currentPage = 2;
                        });
                      },
                      child: ItemNavbar(currentPage == 2 ? true : false,
                          icon: Feather.user, itemName: 'Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemNavbar extends StatelessWidget {
  final active;
  final icon;
  final itemName;
  ItemNavbar(this.active, {this.icon, this.itemName});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 90,
      decoration: BoxDecoration(
        color: active == true ? Colors.blue.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active == true
                ? Colors.blue
                : Color(0xff000000).withOpacity(0.4),
          ),
          SizedBox(height: 5),
          Text(
            itemName,
            style: TextStyle(
              color: active == true
                  ? Colors.blue
                  : Color(0xff000000).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
