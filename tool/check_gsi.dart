import 'dart:io';

void main() {
  final pubCache = Platform.environment['PUB_CACHE'] ?? Platform.environment['LOCALAPPDATA']! + r'\Pub\Cache';
  final dir = Directory(pubCache + r'\hosted\pub.dev');
  final dirs = dir.listSync().whereType<Directory>().where((d) => d.path.contains('google_sign_in-'));
  for (var d in dirs) {
    print(d.path);
    final file = File(d.path + r'\lib\google_sign_in.dart');
    if (file.existsSync()) {
      print(file.readAsStringSync().substring(0, 500));
    }
  }
}
