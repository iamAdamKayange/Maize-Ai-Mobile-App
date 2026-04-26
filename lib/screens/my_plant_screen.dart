import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class MyPlantScreen extends StatefulWidget {
  const MyPlantScreen({super.key});

  @override
  State<MyPlantScreen> createState() => _MyPlantScreenState();
}

class _MyPlantScreenState extends State<MyPlantScreen>
    with SingleTickerProviderStateMixin {
  bool _showAddForm = false;
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  int? _expandedIndex;
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_PlantData> _plants = [
    _PlantData(
      id: '1',
      name: 'Hybrid Maize',
      description: 'High yield variety with disease resistance',
      details: 'Matures in 90-100 days. Excellent for commercial farming.',
      growthStage: 'Flowering Stage',
      healthStatus: 'Healthy',
      imagePath: null,
    ),
    _PlantData(
      id: '2',
      name: 'Local Maize',
      description: 'Traditional variety adapted to local conditions',
      details: 'Matures in 120-150 days. Drought tolerant.',
      growthStage: 'Vegetative Stage',
      healthStatus: 'Good',
      imagePath: null,
    ),
    _PlantData(
      id: '3',
      name: 'Sweet Maize',
      description: 'High sugar content for fresh consumption',
      details: 'Matures in 75-85 days. Best for direct eating.',
      growthStage: 'Harvest Ready',
      healthStatus: 'Excellent',
      imagePath: null,
    ),
    _PlantData(
      id: '4',
      name: 'White Maize',
      description: 'Widely used for flour and porridge',
      details: 'Matures in 100-110 days. High milling quality.',
      growthStage: 'Grain Filling',
      healthStatus: 'Healthy',
      imagePath: null,
    ),
  ];

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image selected successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking image: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addPlant() {
    if (_nameController.text.isNotEmpty && _speciesController.text.isNotEmpty) {
      setState(() {
        _plants.insert(
          0,
          _PlantData(
            id: DateTime.now().toString(),
            name: _nameController.text,
            description: _speciesController.text,
            details: 'Added on ${DateTime.now().toString().substring(0, 10)}',
            growthStage: 'New Plant',
            healthStatus: 'Pending',
            imagePath: _selectedImage,
          ),
        );
        _showAddForm = false;
        _nameController.clear();
        _speciesController.clear();
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Plant added successfully!',
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
        ),
      );
    }
  }

  void _deletePlant(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Plant',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this plant?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _plants.removeWhere((p) => p.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Plant deleted', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantDetails(_PlantData plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: plant.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.file(
                                  plant.imagePath!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.grass_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      plant.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.description,
                      'Description',
                      plant.description,
                    ),
                    _buildInfoRow(Icons.info_outline, 'Details', plant.details),
                    _buildInfoRow(
                      Icons.timeline,
                      'Growth Stage',
                      plant.growthStage,
                    ),
                    _buildInfoRow(
                      Icons.health_and_safety,
                      'Health Status',
                      plant.healthStatus,
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Added Date',
                      plant.details.contains('Added')
                          ? plant.details
                          : 'Not specified',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.softGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: _buildModernAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: _plants.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _plants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => FadeTransition(
                            opacity: _fadeAnimation,
                            child: _PlantCard(
                              plant: _plants[i],
                              isExpanded: _expandedIndex == i,
                              onTap: () => setState(
                                () => _expandedIndex = _expandedIndex == i
                                    ? null
                                    : i,
                              ),
                              onScan: () =>
                                  Navigator.pushNamed(context, '/scanner'),
                              onDetails: () => _showPlantDetails(_plants[i]),
                              onDelete: () => _deletePlant(_plants[i].id),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (_showAddForm)
            GestureDetector(
              onTap: () => setState(() => _showAddForm = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _AddPlantForm(
                      nameController: _nameController,
                      speciesController: _speciesController,
                      selectedImage: _selectedImage,
                      onPickImage: _pickImage,
                      onClose: () => setState(() => _showAddForm = false),
                      onSubmit: _addPlant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _showAddForm = true);
          _animationController.forward();
        },
        backgroundColor: AppTheme.primaryGreen,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  AppBar _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.bgLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.textDark,
            size: 18,
          ),
        ),
      ),
      title: Text(
        'My Plant Collection',
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
            color: AppTheme.bgLight,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.search,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PlantSearchDelegate(_plants),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.grass_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Plants',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '${_plants.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass, size: 80, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text(
            'No plants added yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first plant',
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}

class _PlantData {
  final String id;
  final String name;
  final String description;
  final String details;
  final String growthStage;
  final String healthStatus;
  final File? imagePath;

  _PlantData({
    required this.id,
    required this.name,
    required this.description,
    required this.details,
    required this.growthStage,
    required this.healthStatus,
    this.imagePath,
  });
}

class _PlantCard extends StatelessWidget {
  final _PlantData plant;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onScan;
  final VoidCallback onDetails;
  final VoidCallback onDelete;

  const _PlantCard({
    required this.plant,
    required this.isExpanded,
    required this.onTap,
    required this.onScan,
    required this.onDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: plant.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            plant.imagePath!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.grass_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.softGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionBtn(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan',
                    color: AppTheme.primaryGreen,
                    onTap: onScan,
                  ),
                  _ActionBtn(
                    icon: Icons.info_outline,
                    label: 'Details',
                    color: AppTheme.blue,
                    onTap: onDetails,
                  ),
                  _ActionBtn(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: Colors.red,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPlantForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController speciesController;
  final File? selectedImage;
  final Function(ImageSource) onPickImage;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const _AddPlantForm({
    required this.nameController,
    required this.speciesController,
    required this.selectedImage,
    required this.onPickImage,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Plant',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Plant Name',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Hybrid Maize',
                filled: true,
                fillColor: AppTheme.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Species Description',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: speciesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Describe your plant...',
                filled: true,
                fillColor: AppTheme.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Plant Image',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onPickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text('Gallery', style: GoogleFonts.poppins()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onPickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text('Camera', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedImage != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkGreen,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Add Plant',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantSearchDelegate extends SearchDelegate<_PlantData?> {
  final List<_PlantData> plants;
  _PlantSearchDelegate(this.plants);

  @override
  String get searchFieldLabel => 'Search plants...';

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = plants
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.grass),
        title: Text(results[i].name),
        subtitle: Text(results[i].description),
        onTap: () => close(context, results[i]),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = plants
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.grass),
        title: Text(suggestions[i].name),
        subtitle: Text(suggestions[i].description),
        onTap: () => close(context, suggestions[i]),
      ),
    );
  }
}
