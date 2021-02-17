import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_scanner/models/qrcode.dart';
import 'package:qrcode_scanner/scanner.dart';

import 'dbutils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBUtils _db = DBUtils.instance;
  List<QRCode> _qrcodes = [];

  @override
  void initState() {
    super.initState();
    _getQRCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('QRCode Generator')),
            IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return Scanner();
                  })).then((value) => _getQRCodes());
                })
          ],
        ),
      ),
      body: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: _qrcodes.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: ListTile(
                  leading: QrImage(
                    data: _qrcodes[index].code,
                  ),
                  title: Text(_qrcodes[index].title),
                  subtitle: Text(_qrcodes[index].code),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return Scanner(qrcode: _qrcodes[index]);
                    })).then((value) => _getQRCodes());;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _getQRCodes() async {
    var res = await _db.getQRCodes();
    setState(() {
      _qrcodes = res;
    });
  }
}
