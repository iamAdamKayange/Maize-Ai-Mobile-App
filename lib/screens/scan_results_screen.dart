import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ScanResultsScreen extends StatefulWidget {
  final String diseaseName;
  final double confidence;
  final File imageFile;

  const ScanResultsScreen({
    super.key,
    required this.diseaseName,
    required this.confidence,
    required this.imageFile,
  });

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen>
    with SingleTickerProviderStateMixin {
  bool _showDialog = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Disease information map
  // REPLACE the diseaseDatabase with this:
  static const Map<String, Map<String, String>> diseaseDatabase = {
    'GLS': {
      // ✅ LABEL SAHIHI
      'fullName': 'Gray Leaf Spot',
      'description':
          'Fungal infection (Cercospora zeae-maydis) causing grayish lesions on leaves. This disease can significantly reduce yield if not treated promptly.',
      'severity': 'Moderate',
      'color': '#FF6D00',
    },
    'Healthy': {
      // ✅ LABEL SAHIHI (all caps)
      'fullName': 'Healthy Plant',
      'description':
          'Your maize plant appears to be in good health with no visible disease symptoms. Continue good agricultural practices to maintain plant health.',
      'severity': 'None',
      'color': '#2E7D32',
    },
    'MLN': {
      // ✅ LABEL SAHIHI
      'fullName': 'Maize Lethal Necrosis',
      'description':
          'Serious viral disease caused by combination of Maize chlorotic mottle virus and Sugarcane mosaic virus. Causes leaf drying and potential plant death.',
      'severity': 'Severe',
      'color': '#D32F2F',
    },
    'MSV': {
      // ✅ LABEL SAHIHI
      'fullName': 'Maize Streak Virus',
      'description':
          'Viral disease transmitted by leafhoppers, causing yellow streaks on leaves. Can cause significant yield loss if infection occurs early.',
      'severity': 'High',
      'color': '#F57C00',
    },
  };
  // Prevention measures based on disease
  Map<String, List<Map<String, dynamic>>> getPreventionSteps() {
    final disease = widget.diseaseName;

    if (disease == 'GLS') {
      return {
        'steps': [
          {
            'icon': Icons.delete_outline,
            'title': 'Remove Infected Leaves',
            'color': const Color(0xFFFF6D00),
          },
          {
            'icon': Icons.cleaning_services,
            'title': 'Apply Fungicide (Azoxystrobin)',
            'color': const Color(0xFF2E7D32),
          },
          {
            'icon': Icons.grass,
            'title': 'Plant Resistant Varieties',
            'color': const Color(0xFF0066CC),
          },
          {
            'icon': Icons.water_drop,
            'title': 'Improve Air Circulation',
            'color': const Color(0xFF00ACC1),
          },
          {
            'icon': Icons.rotate_left,
            'title': 'Crop Rotation (2-3 years)',
            'color': const Color(0xFF7B1FA2),
          },
        ],
      };
    } else if (disease == 'MLN') {
      return {
        'steps': [
          {
            'icon': Icons.delete_sweep,
            'title': 'Remove and Destroy Infected Plants',
            'color': const Color(0xFFD32F2F),
          },
          {
            'icon': Icons.bug_report,
            'title': 'Control Vector Insects (Aphids)',
            'color': const Color(0xFFFF6D00),
          },
          {
            'icon': Icons.grass,
            'title': 'Use MLN-Tolerant Varieties',
            'color': const Color(0xFF2E7D32),
          },
          {
            'icon': Icons.agriculture,
            'title': 'Practice Strict Field Hygiene',
            'color': const Color(0xFF0066CC),
          },
          {
            'icon': Icons.timer,
            'title': 'Early Planting to Avoid Vectors',
            'color': const Color(0xFF7B1FA2),
          },
        ],
      };
    } else if (disease == 'MSV') {
      return {
        'steps': [
          {
            'icon': Icons.bug_report,
            'title': 'Control Leafhopper Population',
            'color': const Color(0xFFF57C00),
          },
          {
            'icon': Icons.grass,
            'title': 'Plant MSV-Resistant Cultivars',
            'color': const Color(0xFF2E7D32),
          },
          {
            'icon': Icons.calendar_today,
            'title': 'Adjust Planting Dates',
            'color': const Color(0xFF0066CC),
          },
          {
            'icon': Icons.cleaning_services,
            'title': 'Remove Weed Hosts',
            'color': const Color(0xFF00ACC1),
          },
          {
            'icon': Icons.rotate_left,
            'title': 'Crop Rotation with Non-Hosts',
            'color': const Color(0xFF7B1FA2),
          },
        ],
      };
    } else {
      // Healthy or Unknown
      return {
        'steps': [
          {
            'icon': Icons.water_drop,
            'title': 'Maintain Proper Irrigation',
            'color': const Color(0xFF2E7D32),
          },
          {
            'icon': Icons.grass,
            'title': 'Use Certified Disease-Free Seeds',
            'color': const Color(0xFF0066CC),
          },
          {
            'icon': Icons.agriculture,
            'title': 'Practice Crop Rotation',
            'color': const Color(0xFF00ACC1),
          },
          {
            'icon': Icons.compost,

            'title': 'Balanced Fertilizer Application',
            'color': const Color(0xFFFF6D00),
          },
          {
            'icon': Icons.visibility,
            'title': 'Regular Field Scouting',
            'color': const Color(0xFF7B1FA2),
          },
        ],
      };
    }
  }

  String getDisplayDiseaseName() {
    final disease = widget.diseaseName;
    if (diseaseDatabase.containsKey(disease)) {
      return diseaseDatabase[disease]!['fullName']!;
    }
    return disease;
  }

  String getDiseaseDescription() {
    final disease = widget.diseaseName;
    if (diseaseDatabase.containsKey(disease)) {
      return diseaseDatabase[disease]!['description']!;
    }
    return 'Analysis complete. Please consult an agricultural expert for more information about this condition.';
  }

  Color getSeverityColor() {
    final disease = widget.diseaseName;
    if (diseaseDatabase.containsKey(disease)) {
      final colorHex = diseaseDatabase[disease]!['color']!;
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }
    return AppTheme.primaryGreen;
  }

  String getSeverityLevel() {
    final disease = widget.diseaseName;
    if (diseaseDatabase.containsKey(disease)) {
      return diseaseDatabase[disease]!['severity']!;
    }
    return 'Unknown';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _saveReport() {
    setState(() => _showDialog = true);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = widget.diseaseName == 'Healthy';
    final severityColor = getSeverityColor();
    final preventionData = getPreventionSteps();
    final preventionSteps =
        preventionData['steps'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: _buildModernAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildHeroResultCard(isHealthy, severityColor),
                  ),
                ),
                const SizedBox(height: 24),

                SlideTransition(
                  position: _slideAnimation,
                  child: _buildConfidenceCard(),
                ),
                const SizedBox(height: 24),

                SlideTransition(
                  position: _slideAnimation,
                  child: _buildDiagnosisSection(isHealthy, severityColor),
                ),
                const SizedBox(height: 24),

                SlideTransition(
                  position: _slideAnimation,
                  child: _buildPreventionSection(preventionSteps),
                ),
                const SizedBox(height: 32),

                SlideTransition(
                  position: _slideAnimation,
                  child: _buildActionButtons(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Modern Save Dialog
          if (_showDialog)
            GestureDetector(
              onTap: () => setState(() => _showDialog = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(child: _buildModernSaveDialog()),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  AppBar _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.primaryGreen,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Scan Results',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryGreen,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share feature coming soon',
                    style: GoogleFonts.poppins(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroResultCard(bool isHealthy, Color severityColor) {
    final diseaseDisplayName = getDisplayDiseaseName();

    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHealthy
              ? [
                  const Color(0xFF2E7D32),
                  const Color(0xFF4CAF50),
                  const Color(0xFF66BB6A),
                ]
              : [
                  severityColor,
                  severityColor.withValues(alpha: 0.8),
                  severityColor.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isHealthy
                        ? Icons.health_and_safety_rounded
                        : Icons.warning_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isHealthy
                              ? Colors.green
                              : const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHealthy ? 'HEALTHY PLANT' : 'DISEASE DETECTED',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        diseaseDisplayName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isHealthy
                                ? Icons.check_circle_rounded
                                : Icons.warning_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Maize Plant • ${getSeverityLevel()} Risk',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
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

  Widget _buildConfidenceCard() {
    final confidencePercent = (widget.confidence * 100).toStringAsFixed(1);
    final isHighConfidence = widget.confidence > 0.7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: AppTheme.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Confidence Score',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (isHighConfidence ? AppTheme.primaryGreen : Colors.orange)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isHighConfidence ? 'High Accuracy' : 'Moderate Accuracy',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isHighConfidence
                        ? AppTheme.primaryGreen
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$confidencePercent%',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isHighConfidence
                            ? AppTheme.primaryGreen
                            : Colors.orange,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Confidence Level',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(widget.confidence * 99 + 1).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    Text(
                      'Detection Rate',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: widget.confidence,
              backgroundColor: AppTheme.divider,
              color: isHighConfidence ? AppTheme.primaryGreen : Colors.orange,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppTheme.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Scanned just now',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 12,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI Verified',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection(bool isHealthy, Color severityColor) {
    final description = getDiseaseDescription();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isHealthy
                      ? Icons.health_and_safety_rounded
                      : Icons.healing_rounded,
                  color: severityColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isHealthy ? 'Health Assessment' : 'Diagnosis',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: severityColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  isHealthy
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: severityColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionSection(List<Map<String, dynamic>> preventionSteps) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppTheme.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.diseaseName == 'Healthy'
                    ? 'Maintenance Tips'
                    : 'Prevention Measures',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(preventionSteps.length, (index) {
            final step = preventionSteps[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          step['color'] as Color,
                          (step['color'] as Color).withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      step['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.textGrey,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _saveReport();
            },
            icon: const Icon(Icons.save_alt_rounded, size: 20),
            label: Text(
              'Save Report',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: BorderSide(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pushNamed(context, '/expert-advice');
            },
            icon: const Icon(Icons.support_agent_rounded, size: 20),
            label: Text(
              'Get Expert Help',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSaveDialog() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Report Saved!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your scan result has been saved successfully. You can access it anytime from your history.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _showDialog = false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _showDialog = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Report saved to history!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppTheme.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      HapticFeedback.selectionClick();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'View History',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
