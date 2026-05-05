// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/maize_classifier.dart';
import 'scan_progress_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _cameraInitialized = false;
  bool _modelLoaded = false;
  List<CameraDescription>? _cameras;
  MaizeClassifier? _classifier;

  // Preview mode
  bool _isPreviewMode = false;
  File? _capturedImage;
  XFile? _capturedXFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadModel() async {
    try {
      _classifier = MaizeClassifier();
      await _classifier!.loadModel();
      setState(() {
        _modelLoaded = true;
      });
      print('✅ Model loaded successfully!');
    } catch (e) {
      print('❌ Error loading model: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading AI model: $e')));
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras![0],
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // ✅ Keep original quality
    );

    if (image != null && mounted) {
      final File imageFile = File(image.path);
      final int fileSize = await imageFile.length();
      debugPrint('📸 Gallery image: ${image.path}, size: $fileSize bytes');

      setState(() {
        _capturedXFile = image;
        _capturedImage = imageFile;
        _isPreviewMode = true;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // ✅ Use highest available quality
      final XFile image = await _cameraController!.takePicture();

      // ✅ Verify image was captured
      if (image.path.isEmpty) {
        throw Exception('Empty image path');
      }

      // ✅ Check file size (should be > 0)
      final File imageFile = File(image.path);
      final int fileSize = await imageFile.length();
      debugPrint('📸 Image captured: ${image.path}, size: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      if (mounted) {
        setState(() {
          _capturedXFile = image;
          _capturedImage = imageFile;
          _isPreviewMode = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Camera capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
      }
    }
  }

  Future<void> _startScanning() async {
    if (_capturedImage == null || _classifier == null) return;

    if (!_modelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI model is still loading...')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanProgressScreen(
          imageFile: _capturedImage!,
          classifier: _classifier!,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isPreviewMode = false;
        _capturedImage = null;
        _capturedXFile = null;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _isPreviewMode = false;
      _capturedImage = null;
      _capturedXFile = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isPreviewMode) {
      _cameraController?.resumePreview();
    } else if (state == AppLifecycleState.paused) {
      _cameraController?.pausePreview();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _classifier?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or Captured Image
          if (!_isPreviewMode &&
              _cameraInitialized &&
              _cameraController != null)
            CameraPreview(_cameraController!)
          else if (_isPreviewMode && _capturedImage != null)
            Image.file(
              _capturedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // UI Overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          if (_isPreviewMode) {
                            _retakePhoto();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPreviewMode ? Icons.close : Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Title
                      if (!_isPreviewMode)
                        Text(
                          'Scan Plant',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(100),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                      // Gallery Button
                      if (!_isPreviewMode)
                        GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(128),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                const Spacer(),

                // Preview Mode Controls
                if (_isPreviewMode)
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Image Preview Card
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _capturedImage!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Photo Captured',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ready to analyze this maize plant',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Retake icon
                              GestureDetector(
                                onTap: _retakePhoto,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.refresh,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            // Retake Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _retakePhoto,
                                icon: const Icon(Icons.camera_alt, size: 20),
                                label: Text(
                                  'Retake',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Start Scanning Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _startScanning,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.analytics, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Start Scanning',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Camera Controls (when not in preview mode)
                if (!_isPreviewMode && _cameraInitialized)
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Hint text
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.center_focus_strong,
                                size: 16,
                                color: Colors.white.withAlpha(200),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Center the maize leaf in frame',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Capture Button
                        GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Model loading indicator
                if (!_modelLoaded && !_isPreviewMode)
                  Container(
                    margin: const EdgeInsets.only(bottom: 100),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Loading AI Model...',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !_isPreviewMode
          ? const AppBottomNavBar(currentIndex: 1)
          : null,
    );
  }
}
