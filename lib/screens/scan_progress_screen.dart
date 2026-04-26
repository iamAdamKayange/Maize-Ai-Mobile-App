import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScanProgressScreen extends StatefulWidget {
  const ScanProgressScreen({super.key});

  @override
  State<ScanProgressScreen> createState() => _ScanProgressScreenState();
}

class _ScanProgressScreenState extends State<ScanProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _text = 'Scanning';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _progressValue = _controller.value;
            });
          });

    _controller.forward();
    _animateText();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/scan-results');
    });
  }

  void _animateText() async {
    final texts = ['Scanning', 'Scanning.', 'Scanning..', 'Scanning...'];
    int i = 0;
    while (mounted) {
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
                                  // Plant icon in center
                                  Icon(
                                    Icons.eco,
                                    size: 48,
                                    color: AppTheme.primaryGreen,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _text,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryGreen,
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
