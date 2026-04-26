import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StartedScreen extends StatefulWidget {
  const StartedScreen({super.key});

  @override
  State<StartedScreen> createState() => _StartedScreenState();
}

class _StartedScreenState extends State<StartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
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
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.green.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Plant illustration - Centered
                Expanded(
                  flex: 3,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: const _PlantIllustration(),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // Welcome Text
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        'Welcome to PlantCare',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your personal plant care companion',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                // Get Started button - COMPLETELY FIXED
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/onboarding',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Get Started',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantIllustration extends StatelessWidget {
  const _PlantIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 280,
      width: 280,
      child: CustomPaint(painter: _PlantPainter()),
    );
  }
}

class _PlantPainter extends CustomPainter {
  const _PlantPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Soft shadow under plant
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.88),
        width: 180,
        height: 35,
      ),
      shadowPaint,
    );

    // Decorative circle background
    final bgPaint = Paint()
      ..color = Colors.green.shade50
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 120, bgPaint);

    // Main stem
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path()
      ..moveTo(cx, size.height * 0.82)
      ..cubicTo(
        cx - 8,
        size.height * 0.65,
        cx + 8,
        size.height * 0.45,
        cx,
        size.height * 0.2,
      );
    canvas.drawPath(stemPath, stemPaint);

    // Roots
    final rootPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, size.height * 0.82),
      Offset(cx - 25, size.height * 0.92),
      rootPaint,
    );
    canvas.drawLine(
      Offset(cx, size.height * 0.82),
      Offset(cx + 25, size.height * 0.92),
      rootPaint,
    );
    canvas.drawLine(
      Offset(cx, size.height * 0.82),
      Offset(cx, size.height * 0.94),
      rootPaint,
    );

    // Main leaves
    _drawLeaf(
      canvas,
      Offset(cx - 12, size.height * 0.55),
      -0.65,
      const Color(0xFF388E3C),
      55,
      32,
    );
    _drawLeaf(
      canvas,
      Offset(cx + 12, size.height * 0.45),
      0.75,
      const Color(0xFF4CAF50),
      52,
      30,
    );
    _drawLeaf(
      canvas,
      Offset(cx - 8, size.height * 0.35),
      -0.55,
      const Color(0xFF66BB6A),
      42,
      24,
    );
    _drawLeaf(
      canvas,
      Offset(cx + 6, size.height * 0.28),
      0.6,
      const Color(0xFF81C784),
      38,
      22,
    );
    _drawLeaf(
      canvas,
      Offset(cx, size.height * 0.18),
      0.1,
      const Color(0xFFA5D6A7),
      30,
      18,
    );

    // Corn cob (orange/yellow fruit)
    final cobPaint = Paint()..color = const Color(0xFFF57C00);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 20, size.height * 0.52),
          width: 24,
          height: 38,
        ),
        const Radius.circular(12),
      ),
      cobPaint,
    );

    // Corn cob kernel details
    final kernelPaint = Paint()..color = const Color(0xFFFFB74D);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 2; col++) {
        canvas.drawCircle(
          Offset(cx + 12 + col * 10, size.height * 0.46 + row * 8),
          3.5,
          kernelPaint,
        );
      }
    }

    // Decorative small plants on sides
    // Left small plant
    final smallStemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx - 50, size.height * 0.85),
      Offset(cx - 48, size.height * 0.65),
      smallStemPaint,
    );
    _drawLeaf(
      canvas,
      Offset(cx - 52, size.height * 0.72),
      -0.45,
      const Color(0xFF81C784),
      30,
      18,
    );
    _drawLeaf(
      canvas,
      Offset(cx - 44, size.height * 0.68),
      0.55,
      const Color(0xFFA5D6A7),
      28,
      16,
    );

    // Right small plant with small fruit
    canvas.drawLine(
      Offset(cx + 50, size.height * 0.85),
      Offset(cx + 48, size.height * 0.67),
      smallStemPaint,
    );
    _drawLeaf(
      canvas,
      Offset(cx + 50, size.height * 0.74),
      0.45,
      const Color(0xFF66BB6A),
      28,
      16,
    );

    // Right small fruit
    final smallCobPaint = Paint()..color = const Color(0xFFE65100);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 62, size.height * 0.74),
          width: 14,
          height: 24,
        ),
        const Radius.circular(7),
      ),
      smallCobPaint,
    );

    // Small decorative dots (sparkles)
    final sparklePaint = Paint()..color = Colors.green.shade300;
    canvas.drawCircle(Offset(cx - 40, size.height * 0.35), 3, sparklePaint);
    canvas.drawCircle(Offset(cx + 45, size.height * 0.32), 2.5, sparklePaint);
    canvas.drawCircle(Offset(cx - 35, size.height * 0.22), 2, sparklePaint);
  }

  void _drawLeaf(
    Canvas canvas,
    Offset base,
    double angle,
    Color color,
    double length,
    double width,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-width, -length / 2, 0, -length)
      ..quadraticBezierTo(width, -length / 2, 0, 0)
      ..close();
    canvas.drawPath(path, leafPaint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, 0), Offset(0, -length), veinPaint);

    // Side veins
    for (double i = -length * 0.25; i > -length; i -= length * 0.25) {
      canvas.drawLine(Offset(-2, i), Offset(2, i), veinPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlantPainter old) => false;
}
