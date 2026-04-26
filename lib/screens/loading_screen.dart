import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  // ignore: unused_field
  late Animation<double> _fadeAnim;
  String _loadingText = 'Loading.';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotationAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _animateText();
    _navigateNext();
  }

  void _animateText() async {
    final texts = ['Loading.', 'Loading..', 'Loading...'];
    int i = 0;
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _loadingText = texts[i % texts.length]);
        i++;
      }
    }
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/started');
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: _rotationAnim,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _RingPainter(_rotationAnim.value),
                    child: Center(
                      child: Text(
                        _loadingText,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 14.0;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE8F5E9);
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -1.5708,
      endAngle: -1.5708 + (3.14159 * 2 * 0.75),
      colors: const [Color(0xFF4CAF50), Color(0xFFB2DFDB)],
      transform: GradientRotation(progress * 6.28318),
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.drawArc(
      rect,
      -1.5708 + (progress * 6.28318),
      3.14159 * 2 * 0.75,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
