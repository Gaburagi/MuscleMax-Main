import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_extensions.dart';
import '../models/user_model.dart';
import '../providers/profile_stats_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';

class CustomizationShopScreen extends StatefulWidget {
  const CustomizationShopScreen({super.key});

  @override
  State<CustomizationShopScreen> createState() => _CustomizationShopScreenState();
}

class _CustomizationShopScreenState extends State<CustomizationShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _purchasedItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPurchasedItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchasedItems() async {
    final statsProvider = context.read<ProfileStatsProvider>();
    final purchased = await statsProvider.getPurchasedItems();
    setState(() {
      _purchasedItems = purchased;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = context.watch<GamificationProvider>();
    final currentXP = gamificationProvider.totalXP;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'CUSTOMIZATION SHOP',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$currentXP XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'THEMES'),
            Tab(text: 'FRAMES'),
            Tab(text: 'PATTERNS'),
            Tab(text: 'FEATURES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThemesTab(currentXP),
          _buildFramesTab(currentXP),
          _buildPatternsTab(currentXP),
          _buildFeaturesTab(currentXP),
        ],
      ),
    );
  }

  Widget _buildThemesTab(int currentXP) {
    final themes = ShopItem.catalog.where((item) => item.type == 'theme').toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isPurchased = _purchasedItems.contains(theme.id);
        final canAfford = currentXP >= theme.xpCost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.isAnimated ? Colors.purple : Colors.grey.withOpacity(0.3),
              width: theme.isAnimated ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Preview
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: _getThemeGradient(theme.id),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (theme.isAnimated)
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        theme.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.description,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${theme.xpCost} XP',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        isPurchased
                            ? OutlinedButton(
                                onPressed: () => _applyItem(theme),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.green),
                                ),
                                child: const Text(
                                  'APPLY',
                                  style: TextStyle(color: Colors.green),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: !canAfford ? null : () => _purchaseItem(theme),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: Text(!canAfford ? 'LOCKED' : 'BUY'),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFramesTab(int currentXP) {
    final frames = ShopItem.catalog.where((item) => item.type == 'frame').toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final isPurchased = _purchasedItems.contains(frame.id);
        final canAfford = currentXP >= frame.xpCost;
        final hasAchievement = frame.achievementRequired == null ||
            context.watch<GamificationProvider>().achievements.any(
                  (a) => a.id == frame.achievementRequired && a.isUnlocked,
                );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: frame.name.contains('Legendary')
                  ? Colors.purple
                  : Colors.grey.withOpacity(0.3),
              width: frame.name.contains('Legendary') ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getFrameColor(frame.id),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getFrameColor(frame.id).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.backgroundDark,
                  child: Icon(
                    Icons.person,
                    color: _getFrameColor(frame.id),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                frame.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getFrameColor(frame.id),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (frame.achievementRequired != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.purple, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Achievement',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${frame.xpCost}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: isPurchased
                      ? OutlinedButton(
                          onPressed: () => _applyItem(frame),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'APPLY',
                            style: TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: !canAfford || !hasAchievement
                              ? null
                              : () => _purchaseItem(frame),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            !hasAchievement
                                ? 'LOCKED'
                                : !canAfford
                                    ? 'NEED XP'
                                    : 'BUY',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatternsTab(int currentXP) {
    final patterns = ShopItem.catalog.where((item) => item.type == 'pattern').toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        final isPurchased = _purchasedItems.contains(pattern.id);
        final canAfford = currentXP >= pattern.xpCost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.texture, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pattern.description,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${pattern.xpCost}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  isPurchased
                      ? OutlinedButton(
                          onPressed: () => _applyItem(pattern),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            'APPLY',
                            style: TextStyle(color: Colors.green),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: !canAfford ? null : () => _purchaseItem(pattern),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('BUY'),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturesTab(int currentXP) {
    final features = ShopItem.catalog.where((item) => item.type == 'feature').toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final isPurchased = _purchasedItems.contains(feature.id);
        final canAfford = currentXP >= feature.xpCost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyan.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          feature.description,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${feature.xpCost} XP',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  isPurchased
                      ? OutlinedButton.icon(
                          onPressed: () => _applyItem(feature),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          label: const Text(
                            'APPLY',
                            style: TextStyle(color: Colors.green),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: !canAfford ? null : () => _purchaseItem(feature),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.shopping_cart),
                          label: Text(!canAfford ? 'LOCKED' : 'UNLOCK'),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _purchaseItem(ShopItem item) async {
    final statsProvider = context.read<ProfileStatsProvider>();
    final gamificationProvider = context.read<GamificationProvider>();

    final success = await statsProvider.purchaseShopItem(
      item.id,
      item.xpCost,
      gamificationProvider.totalXP,
    );

    if (success && mounted) {
      setState(() {
        _purchasedItems.add(item.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} purchased! Tap to apply it.'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'APPLY NOW',
            textColor: Colors.white,
            onPressed: () => _applyItem(item),
          ),
        ),
      );
    }
  }

  Future<void> _applyItem(ShopItem item) async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    if (user == null) return;

    try {
      if (item.type == 'theme') {
        // Apply theme
        final theme = _getThemeFromShopItem(item.id);
        await userProvider.updateProfileCustomization(
          profileTheme: theme,
        );
      } else if (item.type == 'frame') {
        // Apply frame
        final frameId = _getFrameIdFromShopItem(item.id);
        await userProvider.updateProfileCustomization(
          profileFrame: frameId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} applied to your profile!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying ${item.name}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ProfileTheme _getThemeFromShopItem(String itemId) {
    switch (itemId) {
      case 'animated_fire':
        return ProfileTheme(
          primaryColor: '#FF4500',
          accentColor: '#FFA500',
          backgroundColor: '#1A1A1A',
          gradientStart: '#FF4500',
          gradientEnd: '#FFA500',
          themeName: 'animated_fire',
        );
      case 'animated_ocean':
        return ProfileTheme(
          primaryColor: '#1E88E5',
          accentColor: '#42A5F5',
          backgroundColor: '#0D47A1',
          gradientStart: '#1E88E5',
          gradientEnd: '#42A5F5',
          themeName: 'animated_ocean',
        );
      case 'animated_neon':
        return ProfileTheme(
          primaryColor: '#00FF00',
          accentColor: '#00FFFF',
          backgroundColor: '#001F1F',
          gradientStart: '#00FF00',
          gradientEnd: '#00FFFF',
          themeName: 'animated_neon',
        );
      default:
        return ProfileTheme.defaultTheme;
    }
  }

  String _getFrameIdFromShopItem(String itemId) {
    if (itemId.contains('dragon')) return 'dragon';
    if (itemId.contains('phoenix')) return 'phoenix';
    if (itemId.contains('titan')) return 'titan';
    if (itemId.contains('diamond')) return 'diamond';
    return 'none';
  }

  LinearGradient _getThemeGradient(String themeId) {
    switch (themeId) {
      case 'animated_fire':
        return const LinearGradient(
          colors: [Color(0xFFFF4500), Color(0xFFFFA500)],
        );
      case 'animated_ocean':
        return const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        );
      case 'animated_neon':
        return const LinearGradient(
          colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
        );
      default:
        return const LinearGradient(
          colors: [Colors.grey, Colors.black],
        );
    }
  }

  Color _getFrameColor(String frameId) {
    if (frameId.contains('dragon')) return Colors.red;
    if (frameId.contains('phoenix')) return Colors.orange;
    if (frameId.contains('titan')) return Colors.purple;
    if (frameId.contains('diamond')) return Colors.cyan;
    return Colors.amber;
  }
}
