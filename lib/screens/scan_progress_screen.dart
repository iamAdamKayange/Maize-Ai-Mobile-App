// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/maize_classifier.dart';
import 'scan_results_screen.dart';

class ScanProgressScreen extends StatefulWidget {
  final File imageFile;
  final MaizeClassifier? classifier;

  const ScanProgressScreen({
    super.key,
    required this.imageFile,
    required this.classifier,
  });

  @override
  State<ScanProgressScreen> createState() => _ScanProgressScreenState();
}

class _ScanProgressScreenState extends State<ScanProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _text = 'Scanning';
  double _progressValue = 0.0;
  Map<String, dynamic>? _result;
  bool _isComplete = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // ✅ Verify image file exists and has content
    if (widget.imageFile.existsSync()) {
      final fileSize = widget.imageFile.lengthSync();
      print(
        '✅ Image file verified: ${widget.imageFile.path}, size: $fileSize bytes',
      );
      if (fileSize == 0) {
        print('❌ WARNING: Image file is empty (0 bytes)!');
        _hasError = true;
        _errorMessage = 'Image file is empty. Please retake photo.';
      }
    } else {
      print('❌ ERROR: Image file does not exist!');
      _hasError = true;
      _errorMessage = 'Image file not found. Please retake photo.';
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _progressValue = _controller.value;
            });
          });

    _controller.forward();
    _animateText();

    // Only perform analysis if no error
    if (!_hasError) {
      _performAnalysis();
    }
  }

  Future<void> _performAnalysis() async {
    try {
      if (widget.classifier != null) {
        debugPrint('🔍 Calling classifier.predict()...');
        _result = await widget.classifier!.predict(widget.imageFile);
        debugPrint('✅ Prediction completed');

        // Show all debug info
        debugPrint('================== ANALYSIS RESULT ==================');
        debugPrint('Disease: ${_result?['disease']}');
        debugPrint('Confidence: ${_result?['confidence']}');
        debugPrint('Confidence %: ${_result?['confidencePercentage']}');
        debugPrint('All predictions: ${_result?['allPredictions']}');
        debugPrint('Info: ${_result?['info']}');
        debugPrint('Error: ${_result?['error']}');
        debugPrint('=====================================================');

        // Check for error
        if (_result?['error'] != null) {
          _hasError = true;
          _errorMessage = _result?['error'] ?? 'Unknown error';
          debugPrint('❌ Prediction error: $_errorMessage');
        } else {
          double conf = _result?['confidence'] ?? 0.0;
          if (conf == 0.0) {
            debugPrint('⚠️ WARNING: Confidence is 0.0');
            _hasError = true;
            _errorMessage =
                'Model returned zero confidence. Please retake photo.';
          } else {
            debugPrint(
              '✅ Valid prediction with ${(conf * 100).toStringAsFixed(2)}% confidence',
            );
          }
        }
      } else {
        debugPrint('❌ Classifier is null!');
        _result = {
          'disease': 'Unknown',
          'confidence': 0.0,
          'error': 'Classifier not loaded',
        };
        _hasError = true;
        _errorMessage = 'AI model not loaded. Please restart app.';
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Analysis exception: $e');
      debugPrint('Stack trace: $stackTrace');
      _result = {
        'disease': 'Analysis Error',
        'confidence': 0.0,
        'error': e.toString(),
      };
      _hasError = true;
      _errorMessage = e.toString();
    }

    setState(() {
      _isComplete = true;
    });

    // Delay then navigate
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultsScreen(
            diseaseName: _hasError
                ? 'Error'
                : (_result?['disease'] ?? 'Unknown'),
            confidence: _hasError ? 0.0 : (_result?['confidence'] ?? 0.0),
            imageFile: widget.imageFile,
          ),
        ),
      );
    }
  }

  void _animateText() async {
    final texts = ['Scanning', 'Scanning.', 'Scanning..', 'Scanning...'];
    int i = 0;
    while (mounted && !_isComplete) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _text = texts[i++ % texts.length]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.green.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Preview ya picha iliyopigwa
              Container(
                margin: const EdgeInsets.all(20),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                  image: DecorationImage(
                    image: FileImage(widget.imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Centered Scan Progress Ring
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background ring
                              CustomPaint(
                                size: const Size(200, 200),
                                painter: _ProgressRingBackgroundPainter(),
                              ),
                              // Animated progress ring
                              CustomPaint(
                                size: const Size(200, 200),
                                painter: _ProgressRingPainter(_progressValue),
                              ),
                              // Center content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 48,
                                    color: _hasError
                                        ? Colors.orange
                                        : AppTheme.primaryGreen,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _hasError ? 'Error' : _text,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: _hasError
                                          ? Colors.orange
                                          : AppTheme.primaryGreen,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(_progressValue * 100).toInt()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Warning message container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF424242), const Color(0xFF616161)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Colors.amber.shade300,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Please Don't Close Screen",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// Background ring painter
class _ProgressRingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = const Color(0xFFE8F5E9)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated progress ring painter
class _ProgressRingPainter extends CustomPainter {
  final double value;

  _ProgressRingPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Start angle at top (-90 degrees)
    const startAngle = -1.5708;
    // Sweep angle (full circle = 6.28318)
    final sweepAngle = 6.28318 * value;

    // Create gradient for the progress ring
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFF4CAF50),
        Color(0xFF66BB6A),
        Color(0xFF81C784),
        Color(0xFFA5D6A7),
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
