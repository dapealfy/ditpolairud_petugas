import 'package:ditpolairud_petugas/settings/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class CardLaporan extends StatefulWidget {
  final data;
  CardLaporan(this.data);
  @override
  _CardLaporanState createState() => _CardLaporanState();
}

class _CardLaporanState extends State<CardLaporan> {
  var warnaProses = Colors.blue;

  colorDecider() {
    setState(() {
      if (widget.data['status'] == 'menunggu verifikasi') {
        warnaProses = Colors.blue;
      } else if (widget.data['status'] == 'diproses') {
        warnaProses = Colors.orange;
      } else if (widget.data['status'] == 'selesai') {
        warnaProses = Colors.green;
      } else if (widget.data['status'] == 'ditolak') {
        warnaProses = Colors.red;
      }
    });
  }

  void initState() {
    colorDecider();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: Offset(
              0.0,
              0.0,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data['status'].toUpperCase(),
            style: TextStyle(color: warnaProses, fontWeight: FontWeight.w500),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 3,
                    decoration: BoxDecoration(
                      color: warnaProses,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode Aduan #' + widget.data['id'].toString(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          widget.data['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.keyboard_arrow_right),
                color: Colors.black.withOpacity(0.6),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Feather.calendar,
                color: Colors.black.withOpacity(0.6),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                waktuFormatter(widget.data['created_at']),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
