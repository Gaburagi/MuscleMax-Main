import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _bioController;
  late TextEditingController _pronounsController;
  
  String? _profilePhotoPath;
  List<String> _coverPhotoPaths = [];
  ProfileTheme? _selectedTheme;
  String? _selectedFrame;
  
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    final user = context.read<UserProvider>().user;
    _bioController = TextEditingController(text: user?.bio ?? '');
    _pronounsController = TextEditingController(text: user?.pronouns ?? '');
    _profilePhotoPath = user?.profilePhoto;
    _coverPhotoPaths = List.from(user?.coverPhotos ?? []);
    _selectedTheme = user?.profileTheme ?? ProfileTheme.defaultTheme;
    _selectedFrame = user?.profileFrame;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (image != null && mounted) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: AppColors.backgroundCard,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      
      if (croppedFile != null) {
        setState(() {
          _profilePhotoPath = croppedFile.path;
        });
      }
    }
  }

  Future<void> _pickCoverPhoto() async {
    if (_coverPhotoPaths.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 cover photos allowed')),
        );
      }
      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (image != null && mounted) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Cover Photo',
            toolbarColor: AppColors.backgroundCard,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Cover Photo',
            aspectRatioLockEnabled: false,
          ),
        ],
      );
      
      if (croppedFile != null) {
        setState(() {
          _coverPhotoPaths = List.from(_coverPhotoPaths)..add(croppedFile.path);
        });
      }
    }
  }

  void _removeCoverPhoto(int index) {
    setState(() {
      _coverPhotoPaths.removeAt(index);
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.updateProfileCustomization(
        profilePhoto: _profilePhotoPath,
        coverPhotos: _coverPhotoPaths,
        pronouns: _pronounsController.text.trim().isEmpty ? null : _pronounsController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        profileTheme: _selectedTheme,
        profileFrame: _selectedFrame,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'CUSTOMIZE PROFILE',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'BASIC'),
            Tab(text: 'THEME'),
            Tab(text: 'FRAMES'),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, color: AppColors.primaryRed),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicTab(),
          _buildThemeTab(),
          _buildFramesTab(),
        ],
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo
          Center(
            child: Column(
              children: [
                const Text(
                  'PROFILE PHOTO',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryRed, width: 3),
                      image: _profilePhotoPath != null
                          ? DecorationImage(
                              image: FileImage(File(_profilePhotoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profilePhotoPath == null
                        ? const Icon(Icons.add_a_photo, size: 40, color: AppColors.textGray)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickProfilePhoto,
                  icon: const Icon(Icons.edit, size: 16, color: AppColors.primaryRed),
                  label: const Text(
                    'Change Photo',
                    style: TextStyle(color: AppColors.primaryRed),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Cover Photos (Telegram-style)
          const Text(
            'COVER PHOTOS (Up to 3)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _coverPhotoPaths.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.panorama, size: 48, color: AppColors.textGray),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickCoverPhoto,
                          icon: const Icon(Icons.add, color: AppColors.primaryRed),
                          label: const Text(
                            'Add Cover Photo',
                            style: TextStyle(color: AppColors.primaryRed),
                          ),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    itemCount: _coverPhotoPaths.length + (_coverPhotoPaths.length < 3 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _coverPhotoPaths.length) {
                        return Center(
                          child: IconButton(
                            icon: const Icon(Icons.add_photo_alternate, size: 48, color: AppColors.primaryRed),
                            onPressed: _pickCoverPhoto,
                          ),
                        );
                      }
                      
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_coverPhotoPaths[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () => _removeCoverPhoto(index),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _coverPhotoPaths.length,
                                (dotIndex) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dotIndex == index
                                        ? AppColors.primaryRed
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Pronouns
          TextField(
            controller: _pronounsController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Pronouns',
              labelStyle: const TextStyle(color: AppColors.textGray),
              hintText: 'e.g., he/him, she/her, they/them',
              hintStyle: const TextStyle(color: AppColors.textGray),
              filled: true,
              fillColor: AppColors.backgroundCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bio
          TextField(
            controller: _bioController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            maxLength: 150,
            decoration: InputDecoration(
              labelText: 'Bio',
              labelStyle: const TextStyle(color: AppColors.textGray),
              hintText: 'Tell us about yourself...',
              hintStyle: const TextStyle(color: AppColors.textGray),
              filled: true,
              fillColor: AppColors.backgroundCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTab() {
    final themes = [
      ProfileTheme.defaultTheme,
      ProfileTheme.fireTheme,
      ProfileTheme.iceTheme,
      ProfileTheme.purpleTheme,
      ProfileTheme.goldTheme,
      ProfileTheme.neonTheme,
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'SELECT YOUR THEME',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...themes.map((theme) => _buildThemeCard(theme)),
      ],
    );
  }

  Widget _buildThemeCard(ProfileTheme theme) {
    final isSelected = _selectedTheme?.themeName == theme.themeName;
    final primaryColor = Color(int.parse('0xFF${theme.primaryColor.substring(1)}'));
    final gradientStart = Color(int.parse('0xFF${theme.gradientStart.substring(1)}'));
    final gradientEnd = Color(int.parse('0xFF${theme.gradientEnd.substring(1)}'));

    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = theme),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart.withOpacity(0.3), gradientEnd.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.white12,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.themeName.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildColorCircle(gradientStart),
                      const SizedBox(width: 8),
                      _buildColorCircle(gradientEnd),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }

  Widget _buildFramesTab() {
    final frames = [
      {'id': null, 'name': 'None', 'icon': Icons.radio_button_unchecked},
      {'id': 'gold', 'name': 'Gold', 'icon': Icons.stars, 'color': Colors.amber},
      {'id': 'diamond', 'name': 'Diamond', 'icon': Icons.diamond, 'color': Colors.cyan},
      {'id': 'fire', 'name': 'Fire', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'id': 'champion', 'name': 'Champion', 'icon': Icons.emoji_events, 'color': Colors.yellow},
      {'id': 'beast', 'name': 'Beast', 'icon': Icons.fitness_center, 'color': AppColors.primaryRed},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final isSelected = _selectedFrame == frame['id'];
        
        return GestureDetector(
          onTap: () => setState(() => _selectedFrame = frame['id'] as String?),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryRed : Colors.white12,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  frame['icon'] as IconData,
                  size: 48,
                  color: frame['color'] as Color? ?? AppColors.textGray,
                ),
                const SizedBox(height: 12),
                Text(
                  frame['name'] as String,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryRed : Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(Icons.check_circle, color: AppColors.primaryRed, size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
