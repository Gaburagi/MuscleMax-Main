import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/gamification_provider.dart';
import '../models/user_model.dart';
import '../utils/routes.dart';
import '../widgets/profile_widgets.dart';
import 'profile_edit_screen.dart';
import 'customization_shop_screen.dart';

class ProfileScreenNew extends StatefulWidget {
  const ProfileScreenNew({super.key});

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  final PageController _coverPageController = PageController();
  int _currentCoverIndex = 0;
  double _scrollOffset = 0;

  @override
  void dispose() {
    _coverPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    
    // Apply user's theme or default
    final theme = user?.profileTheme ?? ProfileTheme.defaultTheme;
    final primaryColor = Color(int.parse('0xFF${theme.primaryColor.substring(1)}'));
    final gradientStart = Color(int.parse('0xFF${theme.gradientStart.substring(1)}'));
    final gradientEnd = Color(int.parse('0xFF${theme.gradientEnd.substring(1)}'));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                setState(() {
                  _scrollOffset = scrollNotification.metrics.pixels;
                });
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
          // Cover Photos (Telegram-style swipeable)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundCard,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(AppRoutes.home),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_bag, color: Colors.amber),
                tooltip: 'Customization Shop',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomizationShopScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Photos or Gradient Background
                  if (user?.coverPhotos.isNotEmpty ?? false)
                    PageView.builder(
                      controller: _coverPageController,
                      onPageChanged: (index) {
                        setState(() => _currentCoverIndex = index);
                      },
                      itemCount: user!.coverPhotos.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(user.coverPhotos[index]),
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gradientStart, gradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  
                  // Gradient overlay for text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  
                  // Dot indicators for cover photos
                  if ((user?.coverPhotos.length ?? 0) > 1)
                    Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          user!.coverPhotos.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentCoverIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentCoverIndex == index
                                  ? primaryColor
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Space for profile pic overlap
                  
                  // Name and pronouns
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'User',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Bebas Neue',
                                letterSpacing: 1.2,
                              ),
                            ),
                            if (user?.pronouns != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user!.pronouns!,
                                style: const TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Level badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [gradientStart, gradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'LVL ${context.watch<GamificationProvider>().userLevel.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const FeaturedBadgesWidget(),
                  
                  // Bio
                  if (user?.bio != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      user!.bio!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Profile Status
                  const ProfileStatusWidget(),
                  
                  // Story Highlights
                  const StoryHighlightsWidget(),
                  const SizedBox(height: 16),
                  
                  // Profile Badges
                  const ProfileBadgesWidget(),
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradientStart.withOpacity(0.2),
                          gradientEnd.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (user?.age != null)
                          _buildStatItem('Age', '${user!.age}', Icons.cake, primaryColor),
                        if (user?.height != null)
                          _buildStatItem('Height', '${user!.height?.toInt()} cm', Icons.height, primaryColor),
                        if (user?.weight != null)
                          _buildStatItem('Weight', '${user!.weight?.toInt()} kg', Icons.monitor_weight, primaryColor),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Fitness Goal
                  if (user?.fitnessGoal != null)
                    _buildInfoCard(
                      'FITNESS GOAL',
                      user!.fitnessGoal!,
                      Icons.flag,
                      primaryColor,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Exercise Preferences
                  if (user?.selectedExercises.isNotEmpty ?? false)
                    _buildInfoCard(
                      'EXERCISE PREFERENCES',
                      user!.selectedExercises.join(', '),
                      Icons.fitness_center,
                      primaryColor,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Profile Stats Showcase
                  const ProfileStatsShowcase(),
                  const SizedBox(height: 16),
                  
                  // Profile Visitors
                  const ProfileVisitorsWidget(),
                  const SizedBox(height: 16),
                  
                  // Workout Anthem
                  const WorkoutAnthemWidget(),
                  const SizedBox(height: 16),
                  
                  // Social Links
                  const SocialLinksWidget(),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileEditScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('EDIT PROFILE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await userProvider.logout();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.logout, color: primaryColor),
                          label: Text('LOGOUT', style: TextStyle(color: primaryColor)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
              ],
            ),
          ),
          // Profile Picture that scrolls with content but stays on top
          Positioned(
            top: 220 - _scrollOffset,
            left: 20,
            child: _buildProfilePicture(user, theme),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfilePicture(UserModel? user, ProfileTheme theme) {
    final primaryColor = Color(int.parse('0xFF${theme.primaryColor.substring(1)}'));
    final frameColor = _getFrameColor(user?.profileFrame);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: frameColor != null
            ? LinearGradient(colors: [frameColor, frameColor.withOpacity(0.6)])
            : null,
        border: Border.all(
          color: frameColor ?? primaryColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (frameColor ?? primaryColor).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.backgroundDark, width: 3),
          image: user?.profilePhoto != null
              ? DecorationImage(
                  image: FileImage(File(user!.profilePhoto!)),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: user?.profilePhoto == null
              ? LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.6)],
                )
              : null,
        ),
        child: user?.profilePhoto == null
            ? const Icon(Icons.person, size: 50, color: Colors.white)
            : null,
      ),
    );
  }

  Color? _getFrameColor(String? frameId) {
    switch (frameId) {
      case 'gold':
        return Colors.amber;
      case 'diamond':
        return Colors.cyan;
      case 'fire':
        return Colors.orange;
      case 'champion':
        return Colors.yellow;
      case 'beast':
        return AppColors.primaryRed;
      case 'dragon':
        return Colors.red.shade900;
      case 'phoenix':
        return Colors.deepOrange;
      case 'titan':
        return Colors.purple.shade700;
      default:
        return null;
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: false,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.fitness_center,
                label: 'Training',
                isSelected: false,
                onTap: () => context.go(AppRoutes.training),
              ),
              _NavItem(
                icon: Icons.bar_chart,
                label: 'Progress',
                isSelected: false,
                onTap: () => context.go(AppRoutes.progress),
              ),
              _NavItem(
                icon: Icons.person,
                label: 'Profile',
                isSelected: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.restaurant,
                label: 'Nutrition',
                isSelected: false,
                onTap: () => context.go(AppRoutes.nutrition),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryRed : AppColors.textGray,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryRed : AppColors.textGray,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
