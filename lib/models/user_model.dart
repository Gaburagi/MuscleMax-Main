import 'profile_extensions.dart';

class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final String? fitnessGoal;
  final List<String> selectedExercises;
  final MacronutrientGoals? macroGoals;
  
  // Profile Customization
  final String? profilePhoto; // Local file path
  final List<String> coverPhotos; // Up to 3 cover photos (Telegram-style)
  final String? pronouns; // he/him, she/her, they/them, etc.
  final String? bio; // User bio/description
  final ProfileTheme? profileTheme; // Custom colors/theme
  final String? profileFrame; // Badge/frame around profile pic
  
  // Profile Stats & Analytics
  final int totalWorkouts; // Lifetime workout count
  final double totalWeightLifted; // Lifetime weight in kg
  final int longestStreak; // Best streak in days
  final String? favoriteExercise; // Most frequently done exercise
  final int totalCaloriesBurned; // Lifetime calories
  final List<String> topPRs; // Top 3 personal records
  
  // Profile Visitors
  final int profileViews; // Total profile view count
  final List<ProfileVisitor> recentVisitors; // Last 20 visitors
  
  // Profile Badges
  final List<String> earnedBadges; // Badge IDs earned
  final List<String> pinnedBadges; // Up to 5 pinned badges
  
  // Profile Status
  final String? currentMood; // Emoji: strong, tired, focused, etc.
  final String? statusText; // 150 char status message
  final DateTime? statusTimestamp; // When status was set
  
  // Profile Links
  final List<SocialLink> socialLinks; // Max 5 custom links
  
  // Profile Story Highlights
  final List<StoryHighlight> storyHighlights; // Story collections
  
  // Profile Music
  final String? workoutAnthem; // Spotify/YouTube link
  final String? anthemTitle; // Song title
  final String? anthemArtist; // Artist name

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.age,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.selectedExercises = const [],
    this.macroGoals,
    this.profilePhoto,
    this.coverPhotos = const [],
    this.pronouns,
    this.bio,
    this.profileTheme,
    this.profileFrame,
    this.totalWorkouts = 0,
    this.totalWeightLifted = 0.0,
    this.longestStreak = 0,
    this.favoriteExercise,
    this.totalCaloriesBurned = 0,
    this.topPRs = const [],
    this.profileViews = 0,
    this.recentVisitors = const [],
    this.earnedBadges = const [],
    this.pinnedBadges = const [],
    this.currentMood,
    this.statusText,
    this.statusTimestamp,
    this.socialLinks = const [],
    this.storyHighlights = const [],
    this.workoutAnthem,
    this.anthemTitle,
    this.anthemArtist,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    int? age,
    double? height,
    double? weight,
    String? fitnessGoal,
    List<String>? selectedExercises,
    MacronutrientGoals? macroGoals,
    String? profilePhoto,
    List<String>? coverPhotos,
    String? pronouns,
    String? bio,
    ProfileTheme? profileTheme,
    String? profileFrame,
    int? totalWorkouts,
    double? totalWeightLifted,
    int? longestStreak,
    String? favoriteExercise,
    int? totalCaloriesBurned,
    List<String>? topPRs,
    int? profileViews,
    List<ProfileVisitor>? recentVisitors,
    List<String>? earnedBadges,
    List<String>? pinnedBadges,
    String? currentMood,
    String? statusText,
    DateTime? statusTimestamp,
    List<SocialLink>? socialLinks,
    List<StoryHighlight>? storyHighlights,
    String? workoutAnthem,
    String? anthemTitle,
    String? anthemArtist,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      selectedExercises: selectedExercises ?? this.selectedExercises,
      macroGoals: macroGoals ?? this.macroGoals,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      coverPhotos: coverPhotos ?? this.coverPhotos,
      pronouns: pronouns ?? this.pronouns,
      bio: bio ?? this.bio,
      profileTheme: profileTheme ?? this.profileTheme,
      profileFrame: profileFrame ?? this.profileFrame,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalWeightLifted: totalWeightLifted ?? this.totalWeightLifted,
      longestStreak: longestStreak ?? this.longestStreak,
      favoriteExercise: favoriteExercise ?? this.favoriteExercise,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      topPRs: topPRs ?? this.topPRs,
      profileViews: profileViews ?? this.profileViews,
      recentVisitors: recentVisitors ?? this.recentVisitors,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      pinnedBadges: pinnedBadges ?? this.pinnedBadges,
      currentMood: currentMood ?? this.currentMood,
      statusText: statusText ?? this.statusText,
      statusTimestamp: statusTimestamp ?? this.statusTimestamp,
      socialLinks: socialLinks ?? this.socialLinks,
      storyHighlights: storyHighlights ?? this.storyHighlights,
      workoutAnthem: workoutAnthem ?? this.workoutAnthem,
      anthemTitle: anthemTitle ?? this.anthemTitle,
      anthemArtist: anthemArtist ?? this.anthemArtist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'selectedExercises': selectedExercises,
      'macroGoals': macroGoals?.toJson(),
      'profilePhoto': profilePhoto,
      'coverPhotos': coverPhotos,
      'pronouns': pronouns,
      'bio': bio,
      'profileTheme': profileTheme?.toJson(),
      'profileFrame': profileFrame,
      'totalWorkouts': totalWorkouts,
      'totalWeightLifted': totalWeightLifted,
      'longestStreak': longestStreak,
      'favoriteExercise': favoriteExercise,
      'totalCaloriesBurned': totalCaloriesBurned,
      'topPRs': topPRs,
      'profileViews': profileViews,
      'recentVisitors': recentVisitors.map((v) => v.toJson()).toList(),
      'earnedBadges': earnedBadges,
      'pinnedBadges': pinnedBadges,
      'currentMood': currentMood,
      'statusText': statusText,
      'statusTimestamp': statusTimestamp?.toIso8601String(),
      'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
      'storyHighlights': storyHighlights.map((h) => h.toJson()).toList(),
      'workoutAnthem': workoutAnthem,
      'anthemTitle': anthemTitle,
      'anthemArtist': anthemArtist,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      age: json['age'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      fitnessGoal: json['fitnessGoal'],
      selectedExercises: json['selectedExercises'] != null
          ? List<String>.from(json['selectedExercises'])
          : [],
      macroGoals: json['macroGoals'] != null
          ? MacronutrientGoals.fromJson(json['macroGoals'])
          : null,
      profilePhoto: json['profilePhoto'],
      coverPhotos: json['coverPhotos'] != null
          ? List<String>.from(json['coverPhotos'])
          : [],
      pronouns: json['pronouns'],
      bio: json['bio'],
      profileTheme: json['profileTheme'] != null
          ? ProfileTheme.fromJson(json['profileTheme'])
          : null,
      profileFrame: json['profileFrame'],
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalWeightLifted: json['totalWeightLifted']?.toDouble() ?? 0.0,
      longestStreak: json['longestStreak'] ?? 0,
      favoriteExercise: json['favoriteExercise'],
      totalCaloriesBurned: json['totalCaloriesBurned'] ?? 0,
      topPRs: json['topPRs'] != null ? List<String>.from(json['topPRs']) : [],
      profileViews: json['profileViews'] ?? 0,
      recentVisitors: json['recentVisitors'] != null
          ? (json['recentVisitors'] as List)
              .map((v) => ProfileVisitor.fromJson(v))
              .toList()
          : [],
      earnedBadges: json['earnedBadges'] != null
          ? List<String>.from(json['earnedBadges'])
          : [],
      pinnedBadges: json['pinnedBadges'] != null
          ? List<String>.from(json['pinnedBadges'])
          : [],
      currentMood: json['currentMood'],
      statusText: json['statusText'],
      statusTimestamp: json['statusTimestamp'] != null
          ? DateTime.parse(json['statusTimestamp'])
          : null,
      socialLinks: json['socialLinks'] != null
          ? (json['socialLinks'] as List)
              .map((l) => SocialLink.fromJson(l))
              .toList()
          : [],
      storyHighlights: json['storyHighlights'] != null
          ? (json['storyHighlights'] as List)
              .map((h) => StoryHighlight.fromJson(h))
              .toList()
          : [],
      workoutAnthem: json['workoutAnthem'],
      anthemTitle: json['anthemTitle'],
      anthemArtist: json['anthemArtist'],
    );
  }
}

// Profile Theme Model (Steam-inspired customization)
class ProfileTheme {
  final String primaryColor; // Hex color
  final String accentColor; // Hex color
  final String backgroundColor; // Hex color
  final String gradientStart; // Hex color
  final String gradientEnd; // Hex color
  final String themeName; // 'default', 'fire', 'ice', 'purple', 'gold', 'custom'

  ProfileTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.themeName,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'gradientStart': gradientStart,
      'gradientEnd': gradientEnd,
      'themeName': themeName,
    };
  }

  factory ProfileTheme.fromJson(Map<String, dynamic> json) {
    return ProfileTheme(
      primaryColor: json['primaryColor'],
      accentColor: json['accentColor'],
      backgroundColor: json['backgroundColor'],
      gradientStart: json['gradientStart'],
      gradientEnd: json['gradientEnd'],
      themeName: json['themeName'],
    );
  }

  // Predefined themes
  static ProfileTheme get defaultTheme => ProfileTheme(
    primaryColor: '#FF3B30',
    accentColor: '#FF9500',
    backgroundColor: '#1C1C1E',
    gradientStart: '#FF3B30',
    gradientEnd: '#FF9500',
    themeName: 'default',
  );

  static ProfileTheme get fireTheme => ProfileTheme(
    primaryColor: '#FF4500',
    accentColor: '#FFD700',
    backgroundColor: '#2C1810',
    gradientStart: '#FF4500',
    gradientEnd: '#FFA500',
    themeName: 'fire',
  );

  static ProfileTheme get iceTheme => ProfileTheme(
    primaryColor: '#00CED1',
    accentColor: '#87CEEB',
    backgroundColor: '#0A1929',
    gradientStart: '#00CED1',
    gradientEnd: '#4682B4',
    themeName: 'ice',
  );

  static ProfileTheme get purpleTheme => ProfileTheme(
    primaryColor: '#9370DB',
    accentColor: '#DA70D6',
    backgroundColor: '#1A0B2E',
    gradientStart: '#9370DB',
    gradientEnd: '#BA55D3',
    themeName: 'purple',
  );

  static ProfileTheme get goldTheme => ProfileTheme(
    primaryColor: '#FFD700',
    accentColor: '#FFA500',
    backgroundColor: '#2B2416',
    gradientStart: '#FFD700',
    gradientEnd: '#FF8C00',
    themeName: 'gold',
  );

  static ProfileTheme get neonTheme => ProfileTheme(
    primaryColor: '#00FF00',
    accentColor: '#00FFFF',
    backgroundColor: '#0D0D0D',
    gradientStart: '#00FF00',
    gradientEnd: '#00FFFF',
    themeName: 'neon',
  );
}

class MacronutrientGoals {
  final int protein; // grams per day
  final int carbs; // grams per day
  final int fat; // grams per day

  MacronutrientGoals({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory MacronutrientGoals.fromJson(Map<String, dynamic> json) {
    return MacronutrientGoals(
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
    );
  }
}
