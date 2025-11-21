import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/body_measurement.dart';
import '../utils/routes.dart';
import '../providers/body_measurement_provider.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class ProgressPhotosScreen extends StatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  String _selectedFilter = 'all'; // all, front, side, back
  ProgressPhoto? _selectedPhotoForComparison;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto(BuildContext context) async {
    final provider = context.read<BodyMeasurementProvider>();
    
    // Show dialog to select photo type
    final type = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Select Photo Type',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPhotoTypeOption(context, 'Front', 'front'),
            _buildPhotoTypeOption(context, 'Side', 'side'),
            _buildPhotoTypeOption(context, 'Back', 'back'),
          ],
        ),
      ),
    );

    if (type == null) return;

    // Pick image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image == null || !context.mounted) return;

    // Get app directory
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/progress_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    // Save image with unique name
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$type${path.extension(image.path)}';
    final savedPath = '${photosDir.path}/$fileName';
    await File(image.path).copy(savedPath);

    // Show weight input dialog
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Photo Details',
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Weight (kg) - Optional',
                labelStyle: const TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryRed),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              style: const TextStyle(color: AppColors.textWhite),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes - Optional',
                labelStyle: const TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryRed),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Delete the saved file if cancelled
              File(savedPath).deleteSync();
              Navigator.pop(context, false);
            },
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final weight = weightController.text.isEmpty 
        ? null 
        : double.tryParse(weightController.text);

    final photo = ProgressPhoto(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      photoPath: savedPath,
      type: type,
      weight: weight,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    
    provider.addPhoto(photo);

    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress photo added!'),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildPhotoTypeOption(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textWhite),
      ),
      leading: Icon(
        value == 'front' ? Icons.person : 
        value == 'side' ? Icons.person_outline :
        Icons.accessibility_new,
        color: AppColors.primaryRed,
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.progressHub),
        ),
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Progress Photos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'Gallery'),
            Tab(text: 'Compare'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGalleryTab(),
          _buildCompareTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPhoto(context),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Consumer<BodyMeasurementProvider>(
      builder: (context, provider, child) {
        final photos = provider.photos;
        
        // Filter photos
        final filteredPhotos = _selectedFilter == 'all'
            ? photos
            : photos.where((p) => p.type == _selectedFilter).toList();

        return Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Front', 'front'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Side', 'side'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Back', 'back'),
                  ],
                ),
              ),
            ),

            // Photo grid
            Expanded(
              child: filteredPhotos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 80,
                            color: AppColors.textGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No progress photos yet',
                            style: TextStyle(
                              color: AppColors.textGray.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap + to add your first photo',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredPhotos.length,
                      itemBuilder: (context, index) {
                        final photo = filteredPhotos[index];
                        return _buildPhotoCard(photo, provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.backgroundCard,
      selectedColor: AppColors.primaryRed,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textWhite : AppColors.textGray,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: AppColors.textWhite,
    );
  }

  Widget _buildPhotoCard(ProgressPhoto photo, BodyMeasurementProvider provider) {
    return GestureDetector(
      onTap: () => _viewPhotoDetails(photo, provider),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textGray.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              Image.file(
                File(photo.photoPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.backgroundCard,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textGray,
                      size: 40,
                    ),
                  );
                },
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(photo.date),
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (photo.weight != null)
                        Text(
                          '${photo.weight!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Type badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    photo.type.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPhotoDetails(ProgressPhoto photo, BodyMeasurementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.backgroundCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(photo.photoPath),
                fit: BoxFit.contain,
                height: 400,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 400,
                    color: AppColors.backgroundDark,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textGray,
                      size: 80,
                    ),
                  );
                },
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM dd, yyyy').format(photo.date),
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          photo.type.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (photo.weight != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.monitor_weight,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${photo.weight!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Notes:',
                      style: TextStyle(
                        color: AppColors.textGray.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      photo.notes!,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            provider.deletePhoto(photo.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo deleted'),
                                backgroundColor: AppColors.primaryRed,
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, color: AppColors.primaryRed),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.primaryRed),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                          ),
                          child: const Text('Close'),
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
    );
  }

  Widget _buildCompareTab() {
    return Consumer<BodyMeasurementProvider>(
      builder: (context, provider, child) {
        final photos = provider.photos;

        if (photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.compare,
                  size: 80,
                  color: AppColors.textGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No photos to compare',
                  style: TextStyle(
                    color: AppColors.textGray.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add at least 2 photos to use comparison',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select photos to compare side-by-side',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Comparison view
              Row(
                children: [
                  Expanded(
                    child: _buildComparisonSlot('Before', photos, true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildComparisonSlot('After', photos, false),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonSlot(String label, List<ProgressPhoto> photos, bool isBefore) {
    final selectedPhoto = isBefore ? _selectedPhotoForComparison : 
        photos.firstWhere((p) => p.id != _selectedPhotoForComparison?.id, 
            orElse: () => photos.first);

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectPhotoForComparison(photos, isBefore),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: selectedPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(selectedPhoto.photoPath),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(selectedPhoto.date),
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (selectedPhoto.weight != null)
                                  Text(
                                    '${selectedPhoto.weight!.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.textGray,
                          size: 60,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to select photo',
                          style: TextStyle(
                            color: AppColors.textGray.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _selectPhotoForComparison(List<ProgressPhoto> photos, bool isBefore) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select ${isBefore ? "Before" : "After"} Photo',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isBefore) {
                          _selectedPhotoForComparison = photo;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photo.photoPath),
                        fit: BoxFit.cover,
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
