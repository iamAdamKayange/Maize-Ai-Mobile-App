import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/drawer_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── Banner state ──
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _autoScrollTimer;

  // UPDATED: Added flag to control flash animation
  bool _isManualNavigation = false;

  // ── Slide-in animation ──
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ── Banner slides data ──
  final List<Map<String, dynamic>> _bannerSlides = [
    {
      'title': 'Detect Disease Early',
      'subtitle': 'AI-powered scanning identifies problems before they spread',
      'color': const Color(0xFF2E7D32),
      'gradient': [const Color(0xFF1B5E20), const Color(0xFF388E3C)],
      'icon': Icons.health_and_safety_rounded,
      'tag': 'NEW',
    },
    {
      'title': 'Protect Your Harvest',
      'subtitle': 'Get instant treatment plans for any maize disease detected',
      'color': const Color(0xFF1565C0),
      'gradient': [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
      'icon': Icons.agriculture_rounded,
      'tag': 'PRO',
    },
    {
      'title': 'Boost Your Yields',
      'subtitle':
          'Expert advice from agricultural scientists at your fingertips',
      'color': const Color(0xFFE65100),
      'gradient': [const Color(0xFFBF360C), const Color(0xFFFF6D00)],
      'icon': Icons.trending_up_rounded,
      'tag': 'TIPS',
    },
  ];

  // ── Disease data ──
  final List<Map<String, dynamic>> _diseases = [
    {
      'name': 'SETOSPHAERIA\nDisease',
      'color': const Color(0xFF2E7D32),
      'severity': 'High',
    },
    {
      'name': 'NORTHERN LEAF\nBlight',
      'color': const Color(0xFF1B5E20),
      'severity': 'Medium',
    },
    {
      'name': 'COMMON\nRust',
      'color': const Color(0xFF33691E),
      'severity': 'Low',
    },
    {
      'name': 'GRAY LEAF\nSpot',
      'color': const Color(0xFF558B2F),
      'severity': 'High',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Setup slide-in animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Auto-scroll timer every 4 seconds
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _isManualNavigation = false; // UPDATED: Mark as auto-scroll
      final next = (_currentBannerIndex + 1) % _bannerSlides.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // ── App bar ──
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leadingWidth: 56,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppTheme.textDark,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                title: Text(
                  'Ai-Maize Detector',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Auto-sliding banner (UPDATED: flash removed) ──
                      _buildBanner(),
                      const SizedBox(height: 26),

                      // ── Quick action chips ──
                      _buildQuickActions(),
                      const SizedBox(height: 26),

                      // ── Common Disease section ──
                      _SectionHeader(
                        title: 'Common Disease',
                        actionLabel: 'See all',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 165,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 4),
                          itemCount: _diseases.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _DiseaseCard(
                            name: _diseases[i]['name'],
                            colorTop: _diseases[i]['color'],
                            severity: _diseases[i]['severity'],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // ── Recently Scanned ──
                      _SectionHeader(
                        title: 'Recently Scanner',
                        actionLabel: 'View all',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      _RecentScanCard(
                        plantName: 'Maize plant was scanned',
                        result: 'Disease Detected',
                        isDisease: true,
                        time: '2 hours ago',
                      ),
                      const SizedBox(height: 10),
                      _RecentScanCard(
                        plantName: 'Maize plant was scanned',
                        result: 'Healthy Plant',
                        isDisease: false,
                        time: '5 hours ago',
                      ),
                      const SizedBox(height: 16),

                      // UPDATED: Added Login/Register button at the bottom
                      _buildAuthButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/scanner'),
        backgroundColor: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 5,
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── AUTO-SLIDING BANNER ──────────────────────────────────────────────────

  Widget _buildBanner() {
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerSlides.length,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
              // UPDATED: Only trigger animation on manual navigation
              if (_isManualNavigation) {
                _animationController.forward(from: 0);
              }
              // Reset flag after handling
              _isManualNavigation = false;
            },
            itemBuilder: (context, index) {
              return _BannerSlide(
                slide: _bannerSlides[index],
                animationController: _animationController,
                onTap: () => Navigator.pushNamed(context, '/scanner'),
              );
            },
          ),

          // Page indicator dots
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerSlides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  width: _currentBannerIndex == index ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.45),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTION CHIPS ───────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Row(
      children: [
        _QuickChip(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan Now',
          color: AppTheme.primaryGreen,
          onTap: () => Navigator.pushNamed(context, '/scanner'),
        ),
        const SizedBox(width: 10),
        _QuickChip(
          icon: Icons.eco_rounded,
          label: 'My Plants',
          color: const Color(0xFF0066CC),
          onTap: () => Navigator.pushNamed(context, '/my-plant'),
        ),
        const SizedBox(width: 10),
        _QuickChip(
          icon: Icons.history_rounded,
          label: 'History',
          color: const Color(0xFFE65100),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAuthButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to expert dashboard (login/register screen inside)
        Navigator.pushNamed(context, '/expert-dashboard');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.primaryGreen.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Login as an Expert or Register',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── BANNER SLIDE WIDGET ──────────────────────────────────────────────────
class _BannerSlide extends StatelessWidget {
  final Map<String, dynamic> slide;
  final AnimationController animationController;
  final VoidCallback onTap;

  const _BannerSlide({
    required this.slide,
    required this.animationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = slide['gradient'] as List<Color>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: (slide['color'] as Color).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // ── Decorative background circles ──
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Tag badge ──
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  slide['tag'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            // ── Icon decoration (top right) ──
            Positioned(
              right: 16,
              top: 44,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  slide['icon'] as IconData,
                  color: Colors.white.withOpacity(0.8),
                  size: 28,
                ),
              ),
            ),

            // ── Text content with staggered animation ──
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title — animates up from below
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (_, __) {
                      final v = animationController.value;
                      final curve = Curves.easeOutBack.transform(
                        v.clamp(0.0, 1.0),
                      );
                      return Transform.translate(
                        offset: Offset(0, 28 * (1 - curve)),
                        child: Opacity(
                          opacity: v.clamp(0.0, 1.0),
                          child: Text(
                            slide['title'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(1, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Subtitle — delayed animation
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (_, __) {
                      final raw = animationController.value;
                      final delayed = ((raw - 0.25) / 0.75).clamp(0.0, 1.0);
                      final curve = Curves.easeOutCubic.transform(delayed);
                      return Transform.translate(
                        offset: Offset(0, 18 * (1 - curve)),
                        child: Opacity(
                          opacity: delayed,
                          child: Text(
                            slide['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // CTA Button — most delayed
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (_, __) {
                      final raw = animationController.value;
                      final delayed = ((raw - 0.45) / 0.55).clamp(0.0, 1.0);
                      final curve = Curves.easeOutCubic.transform(delayed);
                      return Transform.translate(
                        offset: Offset(0, 16 * (1 - curve)),
                        child: Opacity(
                          opacity: delayed,
                          child: GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Explore',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: slide['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: slide['color'] as Color,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── QUICK ACTION CHIP ────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 5),
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
        ),
      ),
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── DISEASE CARD ─────────────────────────────────────────────────────────

class _DiseaseCard extends StatelessWidget {
  final String name;
  final Color colorTop;
  final String severity;

  const _DiseaseCard({
    required this.name,
    required this.colorTop,
    required this.severity,
  });

  Color get _severityColor {
    if (severity == 'High') return AppTheme.errorRed;
    if (severity == 'Medium') return AppTheme.warningOrange;
    return AppTheme.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorTop.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image area with gradient
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorTop, colorTop.withOpacity(0.75)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.grass_rounded,
                    color: Colors.white.withOpacity(0.65),
                    size: 40,
                  ),
                ),
                // Severity badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _severityColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      severity,
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorTop,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View more',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 8,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RECENT SCAN CARD ─────────────────────────────────────────────────────

class _RecentScanCard extends StatelessWidget {
  final String plantName;
  final String result;
  final bool isDisease;
  final String time;

  const _RecentScanCard({
    required this.plantName,
    required this.result,
    required this.isDisease,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isDisease ? AppTheme.errorRed : AppTheme.primaryGreen;
    final statusIcon = isDisease
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Plant thumbnail
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDisease
                  ? AppTheme.errorRed.withOpacity(0.08)
                  : AppTheme.softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.grass_rounded,
              color: isDisease
                  ? AppTheme.errorRed.withOpacity(0.6)
                  : AppTheme.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      result,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/scan-results'),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
