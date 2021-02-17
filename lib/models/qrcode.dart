class QRCode {
  static const tblName = 'qrcode';
  static const colId = 'id';
  static const colTitle = 'title';
  static const colCode = 'code';

  int id;
  String title;
  String code;

  QRCode() {
    id = null;
    title = '';
    code = '';
  }

  QRCode.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    title = map[colTitle];
    code = map[colCode];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: title,
      colCode: code
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
