import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<_OnboardData> _pages = [
    _OnboardData(
      title: 'Early Disease Detection',
      subtitle:
          'Identify maize diseases at an early stage using our advanced AI technology before they spread to your entire crop',
      illustrationType: 0,
      color: const Color(0xFF2E7D32),
      icon: Icons.health_and_safety_rounded,
    ),
    _OnboardData(
      title: 'Snap & Diagnose',
      subtitle:
          'Simply take a photo of your maize plant and get instant AI-powered diagnosis with 95% accuracy in seconds',
      illustrationType: 1,
      color: const Color(0xFF0066CC),
      icon: Icons.qr_code_scanner_rounded,
    ),
    _OnboardData(
      title: 'Expert Treatment Plans',
      subtitle:
          'Receive personalized treatment recommendations from agricultural experts to save your crops and boost yields',
      illustrationType: 2,
      color: const Color(0xFFFF6D00),
      icon: Icons.psychology_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              _pages[_currentPage].color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/dashboard'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() => _currentPage = i);
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: _OnboardPage(data: _pages[i]),
                  ),
                ),
              ),
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    activeDotColor: _pages[_currentPage].color,
                    dotColor: _pages[_currentPage].color.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: _currentPage == 0
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildButton(
                            onPressed: _prevPage,
                            text: 'Back',
                            isPrimary: false,
                            color: _pages[_currentPage].color,
                          ),
                        ),
                      ),
                    Expanded(
                      child: _buildButton(
                        onPressed: _nextPage,
                        text: _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        isPrimary: true,
                        color: _pages[_currentPage].color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required bool isPrimary,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Colors.white,
        border: isPrimary
            ? null
            : Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String subtitle;
  final int illustrationType;
  final Color color;
  final IconData icon;

  _OnboardData({
    required this.title,
    required this.subtitle,
    required this.illustrationType,
    required this.color,
    required this.icon,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // Illustration with decorative background
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [data.color.withValues(alpha: 0.1), Colors.white],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
            child: Center(
              child: SizedBox(
                height: 260,
                width: 260,
                child: _OnboardIllustration(
                  type: data.illustrationType,
                  color: data.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Title with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, color: data.color, size: 24),
                const SizedBox(width: 8),
                Text(
                  data.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: data.color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppTheme.textGrey,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 1),
          // Feature badges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureBadge(Icons.bolt_rounded, 'Fast', data.color),
                const SizedBox(width: 12),
                _buildFeatureBadge(
                  Icons.security_rounded,
                  'Secure',
                  data.color,
                ),
                const SizedBox(width: 12),
                _buildFeatureBadge(
                  Icons.verified_rounded,
                  'Accurate',
                  data.color,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardIllustration extends StatelessWidget {
  final int type;
  final Color color;
  const _OnboardIllustration({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OnboardPainter(type: type, color: color),
      size: const Size(260, 260),
    );
  }
}

class _OnboardPainter extends CustomPainter {
  final int type;
  final Color color;
  _OnboardPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(cx, cy), 100, glowPaint);

    // Shadow base
    final shadowPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, size.height * 0.88),
        width: 160,
        height: 25,
      ),
      shadowPaint,
    );

    if (type == 0) {
      _drawDiseaseDetection(canvas, cx, size.height);
    } else if (type == 1) {
      _drawScanning(canvas, cx, size.height);
    } else {
      _drawTreatment(canvas, cx, size.height);
    }
  }

  void _drawDiseaseDetection(Canvas canvas, double cx, double h) {
    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path()
      ..moveTo(cx, h * 0.85)
      ..cubicTo(cx - 10, h * 0.65, cx + 10, h * 0.45, cx, h * 0.15);
    canvas.drawPath(stemPath, stemPaint);

    // Roots
    final rootPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, h * 0.85), Offset(cx - 30, h * 0.95), rootPaint);
    canvas.drawLine(Offset(cx, h * 0.85), Offset(cx + 30, h * 0.95), rootPaint);

    // Leaves with disease spots
    _drawDiseaseLeaf(canvas, Offset(cx - 12, h * 0.55), -0.6, 58, 32);
    _drawDiseaseLeaf(canvas, Offset(cx + 12, h * 0.45), 0.65, 54, 30);
    _drawDiseaseLeaf(canvas, Offset(cx - 8, h * 0.35), -0.45, 44, 24);
    _drawDiseaseLeaf(canvas, Offset(cx + 8, h * 0.28), 0.4, 38, 20);
    _drawDiseaseLeaf(canvas, Offset(cx, h * 0.18), 0.1, 30, 16);
  }

  void _drawScanning(Canvas canvas, double cx, double h) {
    // Camera/scan frame
    final scanPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final scanRect = Rect.fromCenter(
      center: Offset(cx, h * 0.5),
      width: 140,
      height: 140,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
      scanPaint,
    );

    // Scan corners
    final cornerPaint = Paint()..color = color;
    canvas.drawLine(
      Offset(cx - 70, h * 0.5 - 70),
      Offset(cx - 50, h * 0.5 - 70),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cx - 70, h * 0.5 - 70),
      Offset(cx - 70, h * 0.5 - 50),
      cornerPaint,
    );

    // Plant inside frame
    _drawHealthyPlant(canvas, cx, h * 0.5);

    // Scan line animation effect
    final scanLinePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(cx - 60, h * 0.5),
      Offset(cx + 60, h * 0.5),
      scanLinePaint,
    );
  }

  void _drawTreatment(Canvas canvas, double cx, double h) {
    // Multiple healthy plants
    final positions = [cx - 50, cx, cx + 50];
    for (int i = 0; i < positions.length; i++) {
      final x = positions[i];
      final plantH = h * 0.7;

      // Stem
      final stemPaint = Paint()
        ..color = const Color(0xFF2E7D32)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(x, plantH + 15),
        Offset(x, plantH - 40),
        stemPaint,
      );

      // Leaves
      _drawHealthyLeaf(canvas, Offset(x - 6, plantH - 15), -0.5, 35, 18);
      _drawHealthyLeaf(canvas, Offset(x + 6, plantH - 20), 0.5, 32, 16);

      // Corn cob
      final cobPaint = Paint()..color = const Color(0xFFFFA000);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, plantH - 25),
            width: 16,
            height: 28,
          ),
          const Radius.circular(8),
        ),
        cobPaint,
      );
    }

    // Checkmark for success
    final checkPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path()
      ..moveTo(cx + 35, h * 0.3)
      ..lineTo(cx + 45, h * 0.4)
      ..lineTo(cx + 60, h * 0.25);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawDiseaseLeaf(
    Canvas canvas,
    Offset base,
    double angle,
    double len,
    double w,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final lp = Paint()..color = const Color(0xFF66BB6A);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-w, -len / 2, 0, -len)
      ..quadraticBezierTo(w, -len / 2, 0, 0)
      ..close();
    canvas.drawPath(path, lp);

    // Disease spots
    final sp = Paint()..color = const Color(0xFFFF8F00).withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-w * 0.3, -len * 0.4),
        width: 14,
        height: 10,
      ),
      sp,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.2, -len * 0.65),
        width: 10,
        height: 8,
      ),
      sp,
    );

    canvas.restore();
  }

  void _drawHealthyPlant(Canvas canvas, double cx, double cy) {
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy + 20), Offset(cx, cy - 40), stemPaint);

    _drawHealthyLeaf(canvas, Offset(cx - 8, cy - 10), -0.55, 40, 22);
    _drawHealthyLeaf(canvas, Offset(cx + 8, cy - 15), 0.55, 36, 20);
    _drawHealthyLeaf(canvas, Offset(cx - 5, cy - 30), -0.4, 28, 16);
  }

  void _drawHealthyLeaf(
    Canvas canvas,
    Offset base,
    double angle,
    double len,
    double w,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final lp = Paint()..color = const Color(0xFF4CAF50);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-w, -len / 2, 0, -len)
      ..quadraticBezierTo(w, -len / 2, 0, 0)
      ..close();
    canvas.drawPath(path, lp);

    // Vein
    final veinPaint = Paint()
      ..color = const Color(0xFF2E7D32).withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, 0), Offset(0, -len), veinPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_OnboardPainter old) =>
      old.type != type || old.color != color;
}
