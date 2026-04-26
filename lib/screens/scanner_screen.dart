import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  MobileScannerController? _scannerController;
  bool _isDetecting = false;
  bool _cameraInitialized = false;
  String? _detectedPlant;
  Timer? _detectionTimer;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        print('No cameras found');
        return;
      }

      // Get rear camera (index 0 is usually rear)
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras![0],
      );

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Initialize mobile scanner
      _scannerController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        detectionSpeed: DetectionSpeed.normal,
      );

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }

      // Start detection simulation (for demo)
      _startPlantDetection();
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening camera: $e')));
      }
    }
  }

  void _startPlantDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isDetecting && _cameraInitialized) {
        // Simulate plant detection
        // Katika real app, ungetumia ML model kutambua mimea
        final plants = [
          'Maize Plant',
          'Bean Plant',
          'Tomato Plant',
          'Sunflower',
        ];
        final randomPlant = plants[DateTime.now().second % plants.length];

        setState(() {
          _detectedPlant = randomPlant;
          _isDetecting = true;
        });

        // Auto-hide after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isDetecting = false;
            });
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraController?.resumePreview();
      _scannerController?.start();
    } else if (state == AppLifecycleState.paused) {
      _cameraController?.pausePreview();
      _scannerController?.stop();
    }
  }

  Future<void> _toggleFlash() async {
    if (_scannerController != null) {
      await _scannerController!.toggleTorch();
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (_scannerController != null) {
      await _scannerController!.switchCamera();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    _scannerController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_cameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          if (_cameraInitialized)
            Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    // process hapa
                  },
                ),

                // Hii ndio "child" yako sasa
                Container(color: Colors.transparent),
              ],
            ),

          // Scanner frame and UI
          SafeArea(
            child: Column(
              children: [
                // Top bar with controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleFlash,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _scannerController?.torchEnabled == true
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _switchCamera,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cameraswitch_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hint label
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'Point Camera at Plant',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Scanner frame
                Expanded(
                  child: Center(
                    child: CustomPaint(
                      painter: _ScanFramePainter(),
                      size: const Size(280, 220),
                    ),
                  ),
                ),

                // Detection card
                AnimatedSlide(
                  offset: _detectedPlant != null && _isDetecting
                      ? Offset.zero
                      : const Offset(0, 2),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _detectedPlant != null && _isDetecting ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () {
                        if (_detectedPlant != null) {
                          Navigator.pushNamed(
                            context,
                            '/scan-progress',
                            arguments: {'plantName': _detectedPlant},
                          );
                          setState(() {
                            _isDetecting = false;
                            _detectedPlant = null;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.softGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.grass_rounded,
                                color: AppTheme.primaryGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _detectedPlant ?? 'Plant Detected',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Tap to analyze plant health',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 30.0;
    const r = 8.0;
    final w = size.width;
    final h = size.height;

    // Animated scanning effect
    final scanProgress = (DateTime.now().millisecondsSinceEpoch % 2000) / 2000;
    final scanY = h * scanProgress;

    // Scan line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppTheme.lightGreen.withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY, w, 2))
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, scanY), Offset(w, scanY), linePaint);

    // Draw corners
    // TL corner
    canvas.drawLine(Offset(r, 0), Offset(r + cornerLen, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + cornerLen), paint);
    // TR corner
    canvas.drawLine(Offset(w - r - cornerLen, 0), Offset(w - r, 0), paint);
    canvas.drawLine(Offset(w, r), Offset(w, r + cornerLen), paint);
    // BL corner
    canvas.drawLine(Offset(0, h - r - cornerLen), Offset(0, h - r), paint);
    canvas.drawLine(Offset(r, h), Offset(r + cornerLen, h), paint);
    // BR corner
    canvas.drawLine(Offset(w, h - r - cornerLen), Offset(w, h - r), paint);
    canvas.drawLine(Offset(w - r - cornerLen, h), Offset(w - r, h), paint);

    // Inner border guide
    final guidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final innerRect = Rect.fromLTWH(20, 20, w - 40, h - 40);
    canvas.drawRect(innerRect, guidePaint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) => true;
}
