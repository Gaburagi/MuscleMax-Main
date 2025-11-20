// Profile visitor tracking
class ProfileVisitor {
  final String userId;
  final String userName;
  final String? userAvatar;
  final DateTime visitedAt;

  ProfileVisitor({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'visitedAt': visitedAt.toIso8601String(),
      };

  factory ProfileVisitor.fromJson(Map<String, dynamic> json) => ProfileVisitor(
        userId: json['userId'],
        userName: json['userName'],
        userAvatar: json['userAvatar'],
        visitedAt: DateTime.parse(json['visitedAt']),
      );
}

// Social media links
class SocialLink {
  final String platform; // instagram, tiktok, youtube, website, spotify, custom
  final String url;
  final String? displayName; // Custom display text
  final String icon; // Icon identifier

  SocialLink({
    required this.platform,
    required this.url,
    this.displayName,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'url': url,
        'displayName': displayName,
        'icon': icon,
      };

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        platform: json['platform'],
        url: json['url'],
        displayName: json['displayName'],
        icon: json['icon'],
      );

  // Predefined platforms with icons
  static SocialLink instagram(String username) => SocialLink(
        platform: 'instagram',
        url: 'https://instagram.com/$username',
        icon: 'instagram',
      );

  static SocialLink tiktok(String username) => SocialLink(
        platform: 'tiktok',
        url: 'https://tiktok.com/@$username',
        icon: 'tiktok',
      );

  static SocialLink youtube(String channelUrl) => SocialLink(
        platform: 'youtube',
        url: channelUrl,
        icon: 'youtube',
      );

  static SocialLink spotify(String playlistUrl) => SocialLink(
        platform: 'spotify',
        url: playlistUrl,
        icon: 'spotify',
      );

  static SocialLink website(String url, {String? name}) => SocialLink(
        platform: 'website',
        url: url,
        displayName: name,
        icon: 'link',
      );
}

// Story highlight collections
class StoryHighlight {
  final String id;
  final String title; // Transformation, Best Workouts, PRs, Goals
  final String coverImage; // Local file path for cover
  final List<StoryItem> items; // Up to 10 items
  final DateTime createdAt;
  final bool isPermanent; // True for permanent, false for 24hr expiry

  StoryHighlight({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.items,
    required this.createdAt,
    this.isPermanent = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverImage': coverImage,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'isPermanent': isPermanent,
      };

  factory StoryHighlight.fromJson(Map<String, dynamic> json) => StoryHighlight(
        id: json['id'],
        title: json['title'],
        coverImage: json['coverImage'],
        items: (json['items'] as List).map((i) => StoryItem.fromJson(i)).toList(),
        createdAt: DateTime.parse(json['createdAt']),
        isPermanent: json['isPermanent'] ?? true,
      );
}

// Individual story item
class StoryItem {
  final String id;
  final String type; // photo, video, text
  final String? mediaPath; // Local file path
  final String? caption;
  final DateTime createdAt;

  StoryItem({
    required this.id,
    required this.type,
    this.mediaPath,
    this.caption,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'mediaPath': mediaPath,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StoryItem.fromJson(Map<String, dynamic> json) => StoryItem(
        id: json['id'],
        type: json['type'],
        mediaPath: json['mediaPath'],
        caption: json['caption'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

// Profile badge definitions
class ProfileBadge {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji or icon identifier
  final String category; // streak, achievement, event, exclusive
  final int? requiredValue; // Value needed to unlock
  final String rarity; // common, rare, epic, legendary

  const ProfileBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.requiredValue,
    required this.rarity,
  });

  // Predefined badges
  static const List<ProfileBadge> allBadges = [
    // Streak Badges
    ProfileBadge(
      id: 'streak_7',
      name: '7-Day Warrior',
      description: 'Complete 7 days in a row',
      icon: '🔥',
      category: 'streak',
      requiredValue: 7,
      rarity: 'common',
    ),
    ProfileBadge(
      id: 'streak_30',
      name: 'Monthly Champion',
      description: 'Complete 30 days in a row',
      icon: '💪',
      category: 'streak',
      requiredValue: 30,
      rarity: 'rare',
    ),
    ProfileBadge(
      id: 'streak_100',
      name: 'Century Legend',
      description: 'Complete 100 days in a row',
      icon: '👑',
      category: 'streak',
      requiredValue: 100,
      rarity: 'legendary',
    ),
    
    // Achievement Badges
    ProfileBadge(
      id: 'first_pr',
      name: 'Record Setter',
      description: 'Set your first personal record',
      icon: '🎯',
      category: 'achievement',
      requiredValue: 1,
      rarity: 'common',
    ),
    ProfileBadge(
      id: 'century_club',
      name: 'Century Club',
      description: 'Complete 100 workouts',
      icon: '💯',
      category: 'achievement',
      requiredValue: 100,
      rarity: 'epic',
    ),
    ProfileBadge(
      id: 'beast_mode',
      name: 'Beast Mode',
      description: 'Lift 10,000 kg total',
      icon: '🦍',
      category: 'achievement',
      requiredValue: 10000,
      rarity: 'epic',
    ),
    ProfileBadge(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete 20 morning workouts',
      icon: '🌅',
      category: 'achievement',
      requiredValue: 20,
      rarity: 'rare',
    ),
    ProfileBadge(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Complete 20 evening workouts',
      icon: '🌙',
      category: 'achievement',
      requiredValue: 20,
      rarity: 'rare',
    ),
    
    // Event Badges
    ProfileBadge(
      id: 'summer_2025',
      name: 'Summer Challenge 2025',
      description: 'Participated in Summer Challenge',
      icon: '☀️',
      category: 'event',
      rarity: 'rare',
    ),
    ProfileBadge(
      id: 'holiday_hustle',
      name: 'Holiday Hustle',
      description: 'Stayed active during holidays',
      icon: '🎄',
      category: 'event',
      rarity: 'rare',
    ),
    
    // Exclusive Badges
    ProfileBadge(
      id: 'beta_tester',
      name: 'Beta Tester',
      description: 'Early app tester',
      icon: '🚀',
      category: 'exclusive',
      rarity: 'legendary',
    ),
    ProfileBadge(
      id: 'founder',
      name: 'Founding Member',
      description: 'One of the first users',
      icon: '⭐',
      category: 'exclusive',
      rarity: 'legendary',
    ),
    ProfileBadge(
      id: 'top_1_percent',
      name: 'Top 1%',
      description: 'Elite performer',
      icon: '💎',
      category: 'exclusive',
      rarity: 'legendary',
    ),
  ];

  static ProfileBadge? getBadgeById(String id) {
    try {
      return allBadges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Mood options for profile status
enum ProfileMood {
  strong('💪', 'Feeling Strong'),
  tired('😴', 'Rest Day'),
  beastMode('🔥', 'Beast Mode'),
  focused('🎯', 'Focused'),
  motivated('⚡', 'Motivated'),
  recovering('🧘', 'Recovering'),
  pumped('🚀', 'Pumped Up'),
  relaxed('😌', 'Relaxed');

  final String emoji;
  final String label;

  const ProfileMood(this.emoji, this.label);
}

// Premium shop items
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String type; // theme, frame, pattern, feature
  final int xpCost;
  final String? achievementRequired; // Required achievement ID
  final bool isAnimated;
  final dynamic preview; // Preview data

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.xpCost,
    this.achievementRequired,
    this.isAnimated = false,
    this.preview,
  });

  // Shop catalog
  static const List<ShopItem> catalog = [
    // Animated Themes
    ShopItem(
      id: 'animated_fire',
      name: 'Animated Fire',
      description: 'Blazing gradient animation',
      type: 'theme',
      xpCost: 500,
      isAnimated: true,
    ),
    ShopItem(
      id: 'animated_ocean',
      name: 'Animated Ocean',
      description: 'Flowing water effect',
      type: 'theme',
      xpCost: 500,
      isAnimated: true,
    ),
    ShopItem(
      id: 'animated_neon',
      name: 'Animated Neon',
      description: 'Pulsing neon lights',
      type: 'theme',
      xpCost: 750,
      isAnimated: true,
    ),
    
    // Legendary Frames
    ShopItem(
      id: 'legendary_frame_dragon',
      name: 'Dragon Frame',
      description: 'Legendary dragon glow',
      type: 'frame',
      xpCost: 1000,
    ),
    ShopItem(
      id: 'legendary_frame_phoenix',
      name: 'Phoenix Frame',
      description: 'Rising phoenix effect',
      type: 'frame',
      xpCost: 1000,
    ),
    ShopItem(
      id: 'legendary_frame_titan',
      name: 'Titan Frame',
      description: 'Godlike presence',
      type: 'frame',
      xpCost: 1500,
    ),
    
    // Custom Features
    ShopItem(
      id: 'custom_color_picker',
      name: 'Custom Color Picker',
      description: 'Create your own theme',
      type: 'feature',
      xpCost: 750,
    ),
    ShopItem(
      id: 'profile_patterns',
      name: 'Background Patterns',
      description: 'Add texture to profile',
      type: 'pattern',
      xpCost: 600,
    ),
    
    // Achievement Unlocks
    ShopItem(
      id: 'diamond_frame_unlock',
      name: 'Diamond Frame',
      description: 'Unlocked at 100 workouts',
      type: 'frame',
      xpCost: 0,
      achievementRequired: 'century_club',
    ),
    ShopItem(
      id: 'fire_theme_unlock',
      name: 'Eternal Fire Theme',
      description: 'Unlocked with 30-day streak',
      type: 'theme',
      xpCost: 0,
      achievementRequired: 'streak_30',
    ),
  ];
}
