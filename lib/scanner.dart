import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_scanner/dbutils.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Directory pickedDirectory;

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
        title: Row(
          children: [
            Expanded(child: Text('Scanner')),
            // IconButton(
            //     icon: Icon(Icons.file_download),
            //     onPressed: () {
            //       _exportQRCode();
            //     }),
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  _saveQRCode();
                }),
            IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  // var res = await BarcodeScanner.scan();
                  var res = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);

                  setState(() {
                    _qrcode.code = res;
                    _ctrlCode.text = res;
                  });
                })
          ],
        ),
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
                  decoration: InputDecoration(labelText: 'Code'),
                  controller: _ctrlCode,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  onChanged: (val) {
                    setState(() {
                      _qrcode.code = val;
                    });
                  }),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: InkWell(
                  child: QrImage(data: _qrcode.code, padding: EdgeInsets.all(10), backgroundColor: Colors.white),
                  onTap: () {
                    _tryBrowse(_qrcode.code);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _tryBrowse(url) async {
    if (await canLaunch(url)) {
      print('asd');
      await launch(url);
    }
    print(url);
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

  // _exportQRCode() async {
  //   // String path = await FilesystemPicker.open(title: 'Open file', context: context, fsType: FilesystemType.folder, pickText: 'Save file to this folder', rootDirectory: await getExternalStorageDirectory());

  //   // print(path);
  //   var dir = await getApplicationDocumentsDirectory();
  //   print(dir.path);
  //   Navigator.of(context).push<FolderPickerPage>(MaterialPageRoute(builder: (BuildContext context) {
  //     return FolderPickerPage(
  //         rootDirectory: dir,
  //         action: (BuildContext context, Directory folder) async {
  //           print("Picked directory $folder");
  //           setState(() => pickedDirectory = folder);
  //           Navigator.of(context).pop();
  //         });
  //   }));
  // }
}
