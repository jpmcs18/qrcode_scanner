import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
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
    _getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('QRCodes')),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return Scanner();
                  })).then((value) => _getQRCodes());
                })
          ],
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _qrcodes.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return Scanner(qrcode: _qrcodes[index]);
                  })).then((value) => _getQRCodes());
                },
                child: Dismissible(
                  direction: DismissDirection.endToStart,
                  key: Key(_qrcodes[index].code),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) _deleteQRCode(_qrcodes[index]);
                  },
                  background: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                        color: Colors.red,
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.all(25),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      )),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        QrImage(
                          data: _qrcodes[index].code,
                          backgroundColor: Colors.white,
                          size: 80,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _qrcodes[index].title,
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(_qrcodes[index].code)
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              ),
              elevation: 10,
            );
          },
        ),
      ),
    );
  }

  _getPermissions() async {
    final permissions = await Permission.getPermissionsStatus([
      PermissionName.Storage
    ]);
    var request = true;
    switch (permissions[0].permissionStatus) {
      case PermissionStatus.allow:
        request = false;
        break;
      case PermissionStatus.always:
        request = false;
        break;
      default:
    }
    if (request) {
      await Permission.requestPermissions([
        PermissionName.Storage
      ]);
    }
  }

  _getQRCodes() async {
    var res = await _db.getQRCodes();
    setState(() {
      _qrcodes = res;
    });
  }

  _deleteQRCode(QRCode qrcode) async {
    await _db.deleteQRCode(qrcode.id);
    setState(() {
      _qrcodes.remove(qrcode);
    });
  }
}
