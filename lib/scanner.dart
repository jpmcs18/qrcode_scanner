import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_scanner/dbutils.dart';

import 'models/qrcode.dart';

class Scanner extends StatefulWidget {
  Scanner({this.qrcode});

  final QRCode qrcode;
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  DBUtils _db = DBUtils.instance;
  QRCode _qrcode = QRCode();

  final _ctrlTitle = TextEditingController();
  final _ctrlCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _qrcode = widget.qrcode == null ? QRCode() : widget.qrcode;
      _ctrlTitle.text = _qrcode.title;
      _ctrlCode.text = _qrcode.code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
      ),
      body: Card(
        margin: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: _ctrlTitle,
                onChanged: (val) {
                  setState(() {
                    _qrcode.title = val;
                  });
                },
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(labelText: 'Code'),
                controller: _ctrlCode,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              Expanded(
                  child: QrImage(
                data: _qrcode.code,
              )),
              FlatButton(
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.blue, width: 2)),
                onPressed: () {
                  _saveQRCode();
                },
                child: Text('Save'),
              ),
              FlatButton(
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.blue, width: 2)),
                onPressed: () async {
                  var res = await BarcodeScanner.scan();
                  setState(() {
                    _qrcode.code = res;
                    _ctrlCode.text = res;
                  });
                },
                child: Text('Scan'),
              )
            ],
          ),
        ),
      ),
    );
  }

  _saveQRCode() async {
    int x = 0;
    if (_qrcode.id == null)
      x = await _db.insertQRCode(_qrcode);
    else
      x = await _db.updateQRCode(_qrcode);

    setState(() {
      _qrcode = QRCode();
      _ctrlTitle.clear();
      _ctrlCode.clear();
    });

    Navigator.of(context).pop();
  }
}
