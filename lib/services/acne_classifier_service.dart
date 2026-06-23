import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AcneClassifierService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  static const int inputSize = 224;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/ml/model_unquant.tflite');
    final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
    _labels = labelsData
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
      final parts = line.trim().split(' ');
      return parts.length > 1 ? parts.sublist(1).join(' ') : line.trim();
    })
        .toList();
  }

  Future<Map<String, dynamic>> classify(File imageFile) async {
    if (_interpreter == null) {
      throw Exception("Model not loaded. Call loadModel() first.");
    }

    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) throw Exception("Could not decode image");

    final resized = img.copyResize(rawImage, width: inputSize, height: inputSize);

    var input = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (y) => List.generate(
          inputSize,
              (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1,
              (pixel.g / 127.5) - 1,
              (pixel.b / 127.5) - 1,
            ];
          },
        ),
      ),
    );

    var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    _interpreter!.run(input, output);

    final scores = output[0] as List<double>;
    double maxScore = -1;
    int maxIndex = 0;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    return {"label": _labels[maxIndex], "confidence": maxScore};
  }

  void close() {
    _interpreter?.close();
  }
}