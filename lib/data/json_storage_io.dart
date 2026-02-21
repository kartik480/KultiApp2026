import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> readJsonFile(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  if (await file.exists()) return file.readAsString();
  return null;
}

Future<void> writeJsonFile(String filename, String content) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content, flush: true);
}
