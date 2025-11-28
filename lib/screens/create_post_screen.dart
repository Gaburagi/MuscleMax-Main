import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/social_provider.dart';
import '../utils/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _workoutNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _exercisesController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _xpController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  bool _isPosting = false;
  List<XFile> _selectedImages = [];
  List<XFile> _selectedVideos = [];
  String _postType = 'general'; // 'general', 'workout'

  @override
  void dispose() {
    _workoutNameController.dispose();
    _noteController.dispose();
    _durationController.dispose();
    _exercisesController.dispose();
    _caloriesController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          // Limit to 4 images max
          if (_selectedImages.length > 4) {
            _selectedImages = _selectedImages.take(4).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        setState(() {
          _selectedVideos.add(video);
          // Limit to 1 video max
          if (_selectedVideos.length > 1) {
            _selectedVideos = _selectedVideos.take(1).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    // For general posts, content is required
    if (_postType == 'general' && _noteController.text.trim().isEmpty && _selectedImages.isEmpty && _selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to your post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For workout posts, workout name is required
    if (_postType == 'workout' && _workoutNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a workout name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    final socialProvider = context.read<SocialProvider>();
    
    // Convert XFile paths to strings (in production, upload to server first)
    final imagePaths = _selectedImages.map((img) => img.path).toList();
    final videoPaths = _selectedVideos.map((vid) => vid.path).toList();
    
    await socialProvider.postWorkout(
      workoutName: _postType == 'workout' ? _workoutNameController.text.trim() : null,
      durationMinutes: _postType == 'workout' ? (int.tryParse(_durationController.text) ?? 0) : null,
      exercisesCompleted: _postType == 'workout' ? (int.tryParse(_exercisesController.text) ?? 0) : null,
      caloriesBurned: _postType == 'workout' ? int.tryParse(_caloriesController.text) : null,
      xpGained: _postType == 'workout' ? (int.tryParse(_xpController.text) ?? 0) : null,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      imageUrls: imagePaths,
      videoUrls: videoPaths,
      postType: _postType,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post shared successfully!'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CREATE POST',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _createPost,
            child: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'POST',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Type Selector
            const Text(
              'POST TYPE',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPostTypeButton(
                    label: 'General',
                    icon: Icons.chat_bubble,
                    type: 'general',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPostTypeButton(
                    label: 'Workout',
                    icon: Icons.fitness_center,
                    type: 'workout',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content/Note (Always visible)
            const Text(
              'WHAT\'S ON YOUR MIND?',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Share your thoughts, progress, or motivation...',
                hintStyle: const TextStyle(color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Workout Name (Only for workout posts)
            if (_postType == 'workout') ...[
              const Text(
                'WORKOUT NAME *',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _workoutNameController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g., Upper Body Strength',
                  hintStyle: const TextStyle(color: AppColors.textGray),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Media Picker
            const Text(
              'PHOTOS & VIDEOS (OPTIONAL)',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add photo button
                  InkWell(
                    onTap: _selectedImages.length < 4 && _selectedVideos.isEmpty ? _pickImages : null,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedImages.length < 4 && _selectedVideos.isEmpty
                              ? Colors.blue.withOpacity(0.5)
                              : AppColors.textGray.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            color: _selectedImages.length < 4 && _selectedVideos.isEmpty
                                ? Colors.blue
                                : AppColors.textGray,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Photo',
                            style: TextStyle(
                              color: _selectedImages.length < 4 && _selectedVideos.isEmpty
                                  ? Colors.blue
                                  : AppColors.textGray,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Add video button
                  InkWell(
                    onTap: _selectedVideos.isEmpty && _selectedImages.isEmpty ? _pickVideo : null,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedVideos.isEmpty && _selectedImages.isEmpty
                              ? Colors.purple.withOpacity(0.5)
                              : AppColors.textGray.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            color: _selectedVideos.isEmpty && _selectedImages.isEmpty
                                ? Colors.purple
                                : AppColors.textGray,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Video',
                            style: TextStyle(
                              color: _selectedVideos.isEmpty && _selectedImages.isEmpty
                                  ? Colors.purple
                                  : AppColors.textGray,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Selected images
                  ..._selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(image.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Selected videos
                  ..._selectedVideos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final video = entry.value;
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple, width: 2),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(Icons.play_circle_filled, color: Colors.purple, size: 40),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => _removeVideo(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Workout Stats (Only for workout posts)
            if (_postType == 'workout') ...[
              const Text(
                'WORKOUT DETAILS (OPTIONAL)',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatField(
                    label: 'Duration (min)',
                    controller: _durationController,
                    icon: Icons.timer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatField(
                    label: 'Exercises',
                    controller: _exercisesController,
                    icon: Icons.fitness_center,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatField(
                    label: 'Calories',
                    controller: _caloriesController,
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatField(
                    label: 'XP Gained',
                    controller: _xpController,
                    icon: Icons.star,
                  ),
                ),
              ],
            ),

              const SizedBox(height: 32),
            ],

            // Info message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryRed.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your post will be visible to all community members',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeButton({
    required String label,
    required IconData icon,
    required String type,
  }) {
    final isSelected = _postType == type;
    return InkWell(
      onTap: () => setState(() => _postType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed.withOpacity(0.2) : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : AppColors.textGray.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryRed : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryRed : Colors.white,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textGray),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.textGray),
            filled: true,
            fillColor: AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
