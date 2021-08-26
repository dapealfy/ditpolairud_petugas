import 'package:intl/intl.dart';

String replaceCharAt(String oldString, int index, String newChar) {
  return oldString.substring(0, index) +
      newChar +
      oldString.substring(index + 1);
}

String waktuFormatter(data) {
  var _waktu = replaceCharAt(data, 10, " ");
  var waktu =
      DateTime.parse(replaceCharAt(_waktu, 26, "")).add(Duration(hours: 8));
  return DateFormat('d MMM yyyy').format(waktu).toString();
}
