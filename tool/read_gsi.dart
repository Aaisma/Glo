import 'dart:io';

void main() {
  final pubCache = Platform.environment['PUB_CACHE'] ?? Platform.environment['LOCALAPPDATA']! + r'\Pub\Cache';
  final dir = Directory(pubCache + r'\hosted\pub.dev');
  final dirs = dir.listSync().whereType<Directory>().where((d) => d.path.contains('google_sign_in-7.2.0'));
  for (var d in dirs) {
    final file = File(d.path + r'\lib\google_sign_in.dart');
    if (file.existsSync()) {
      print(file.readAsStringSync());
    }
  }
}
