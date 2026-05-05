import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

class MaizeClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isLoaded = false;

  static const int _inputSize = 224;

  /// Disease information
  static const Map<String, String> diseaseInfo = {
    'GLS': 'Fungal disease causing gray rectangular lesions on maize leaves',
    'MLN':
        'Maize Lethal Necrosis (MLN) - viral disease causing stunting, yellowing and leaf necrosis',
    'MSV':
        'Maize Streak Virus (MSV) - viral disease causing yellow streaks on leaves and reduced growth',
    'Healthy': 'Plant is healthy with no visible disease symptoms',
  };

  // =========================
  // LOAD MODEL
  // =========================
  Future<void> loadModel() async {
    try {
      debugPrint('📂 Loading model...');

      final modelBuffer = await rootBundle.load(
        'assets/models/maize_effnetb0_finetuned_fp16.tflite',
      );

      final labelsBuffer = await rootBundle.loadString(
        'assets/models/labels.txt',
      );

      _labels = labelsBuffer
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;

      _interpreter = Interpreter.fromBuffer(
        modelBuffer.buffer.asUint8List(),
        options: options,
      );

      // 🔍 Debug tensor info
      final inputTensor = _interpreter.getInputTensor(0);
      final outputTensor = _interpreter.getOutputTensor(0);

      debugPrint(' Input shape: ${inputTensor.shape}');
      debugPrint('Output shape: ${outputTensor.shape}');
      debugPrint('Labels: $_labels');

      _isLoaded = true;

      debugPrint('Model loaded successfully');
    } catch (e, s) {
      debugPrint('Model load failed: $e');
      debugPrint('$s');
      _isLoaded = false;
      rethrow;
    }
  }

  // =========================
  // PREDICT FUNCTION
  // =========================
  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (!_isLoaded) {
      throw Exception("Model not loaded");
    }

    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception("Cannot decode image");
      }

      // Resize
      image = img.copyResize(image, width: _inputSize, height: _inputSize);

      // INPUT buffer
      List<double> input = List.filled(1 * _inputSize * _inputSize * 3, 0.0);

      int index = 0;

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = image.getPixel(x, y);

          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          // EfficientNet normalization [-1,1]
          input[index++] = (r / 127.5) - 1;
          input[index++] = (g / 127.5) - 1;
          input[index++] = (b / 127.5) - 1;
        }
      }

      var inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);

      var output = List.filled(
        1 * _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      _interpreter.run(inputTensor, output);

      List<double> results = List<double>.from(output[0]);

      // =========================
      // OPTIONAL SOFTMAX FIX
      // (in case model has no softmax)
      // =========================
      double sum = results.reduce((a, b) => a + b);
      if (sum > 0 && sum <= 1.5) {
        // already normalized (likely softmax)
      } else {
        results = results.map((e) => e / sum).toList();
      }

      // =========================
      // DEBUG ALL RESULTS
      // =========================
      for (int i = 0; i < results.length; i++) {
        debugPrint("${_labels[i]}: ${results[i]}");
      }

      // FIND BEST MATCH
      double maxProb = results[0];
      int maxIndex = 0;

      for (int i = 1; i < results.length; i++) {
        if (results[i] > maxProb) {
          maxProb = results[i];
          maxIndex = i;
        }
      }

      String label = _labels[maxIndex];

      return {
        "disease": label,
        "confidence": maxProb,
        "confidencePercent": (maxProb * 100),
        "info": diseaseInfo[label] ?? "No info available",
        "allResults": results,
      };
    } catch (e, s) {
      debugPrint("❌ Prediction error: $e");
      debugPrint("$s");

      return {"disease": "Unknown", "confidence": 0.0, "error": e.toString()};
    }
  }

  // =========================
  // DISPOSE
  // =========================
  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
    }
  }
}
