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
  List<Directory> selectedDir = [];
  Future<Uint8List> _qrCode;
  int cnt = 0;
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
        children: [Expanded(child: Text('Select Folder'))],
      )),
      body: Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedDir.map((e) {
                var normal = Paint();
                normal.color = Colors.white;
                var current = Paint();
                current.color = Colors.blue;
                var w = Container(
                    child: Row(children: [
                  Icon(Icons.arrow_right),
                  InkWell(
                    child: Container(
                      child: Text(
                        basename(e.path),
                        style: TextStyle(
                            foreground: (cnt != selectedDir.length - 1)
                                ? normal
                                : current),
                      ),
                      margin: EdgeInsets.all(5),
                    ),
                    onTap: () {
                      _getFolder(e);
                    },
                  )
                ]));

                setState(() {
                  cnt++;
                });

                return w;
              }).toList(),
            ),
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.folder),
                    title: Container(
                      child: Text(
                        basename(folders[index].path),
                      ),
                      margin: EdgeInsets.all(5),
                    ),
                    onTap: () {
                      _getFolder(folders[index]);
                    },
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
                      _saveQRCode(context);
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
            if ((await FileSystemEntity.type(p.path)) ==
                FileSystemEntityType.directory) return p;
            return null;
          })
          .where((event) => event != null)
          .toList();
      setState(() {
        dir = directory;
        folders = d;
        _breakDownFolder();
      });
    } else {
      Permission.storage.request();
      _getFolder(directory);
    }
  }

  _breakDownFolder() {
    selectedDir.clear();
    cnt = 0;
    List<String> folders = dir.path.split('/');
    String str = '';
    for (int i = 1; i < folders.length; i++) {
      str += '/' + folders[i];
      if (i > 2) selectedDir.add(Directory(str));
    }
  }

  _saveQRCode(context) async {
    var path = join(dir.path, '${_ctrlFileName.text}.png');

    final file = await new File(path).create();
    await file.writeAsBytes(await _qrCode);

    Navigator.of(context).pop();
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
