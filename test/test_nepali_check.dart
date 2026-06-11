import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';

void main() {
  test('test formatting in nepali utils', () {
    final now = NepaliDateTime.now();
    print("DEFAULT FORMAT: ${NepaliDateFormat('MMMM yyyy').format(now)}");
    print("ENGLISH LANGUAGE FORMAT: ${NepaliDateFormat('MMMM yyyy', Language.english).format(now)}");
    print("NEPALI LANGUAGE FORMAT: ${NepaliDateFormat('MMMM yyyy', Language.nepali).format(now)}");
  });
}
