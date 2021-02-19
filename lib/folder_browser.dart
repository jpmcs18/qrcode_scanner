import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class FolderBrowser extends StatefulWidget {
  FolderBrowser(this.qrcode);
  final Future<Uint8List> qrcode;
  @override
  _FolderBrowserState createState() => _FolderBrowserState();
}

class _FolderBrowserState extends State<FolderBrowser> {
  List<Directory> folders = [];
  Directory dir;
  Future<Uint8List> _qrCode;
  final _ctrlFileName = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _qrCode = widget.qrcode;
    });
    _initializeFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Select Folder'))
          ],
        ),
      ),
      body: Column(children: [
        Row(children: [
          Expanded(
              child: Card(
            child: InkWell(
              child: Container(
                margin: EdgeInsets.all(5),
                child: Text(dir == null ? '' : dir.path, style: TextStyle(fontSize: 20.0)),
                alignment: Alignment.centerLeft,
              ),
              onTap: () {
                _getFolder(dir.parent);
              },
            ),
          ))
        ]),
        Expanded(
            child: ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(5),
                    child: InkWell(
                      child: Container(
                        child: Text(
                          basename(folders[index].path),
                          style: TextStyle(fontSize: 25.0),
                        ),
                        margin: EdgeInsets.all(5),
                      ),
                      onTap: () {
                        _getFolder(folders[index]);
                      },
                    ),
                  );
                })),
        Card(
          child: Container(
            margin: EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _ctrlFileName,
                  decoration: InputDecoration(hintText: 'image name'),
                )),
                IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      _sqveQRCode(context);
                    })
              ],
            ),
          ),
        )
      ]),
    );
  }

  _initializeFolders() async {
    var mainFolder = await ExtStorage.getExternalStorageDirectory();
    _getFolder(Directory(mainFolder));
  }

  _getFolder(Directory directory) async {
    var permission = await Permission.storage.status;
    if (permission.isGranted) {
      List<Directory> d = await directory
          .list()
          .asyncMap((event) async {
            var p = Directory(event.path);
            if ((await FileSystemEntity.type(p.path)) == FileSystemEntityType.directory) return p;
            return null;
          })
          .where((event) => event != null)
          .toList();
      setState(() {
        dir = directory;
        folders = d;
      });
    } else {
      Permission.storage.request();
      _getFolder(directory);
    }
  }

  _sqveQRCode(context) async {
    var path = join(dir.path, '${_ctrlFileName.text}.png');

    final file = await new File(path).create();
    await file.writeAsBytes(await _qrCode);

    Navigator.of(context).pop();
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
