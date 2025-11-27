import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'utils/routes.dart';
import 'providers/user_provider.dart';
import 'providers/profile_stats_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/custom_workout_provider.dart';
import 'providers/community_provider.dart';
import 'providers/friends_provider.dart';
import 'providers/body_measurement_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/social_provider.dart';
import 'providers/ai_workout_provider.dart';

void main() {
  runApp(const MuscleMaxApp());
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

class MuscleMaxApp extends StatefulWidget {
  const MuscleMaxApp({super.key});

  @override
  State<MuscleMaxApp> createState() => _MuscleMaxAppState();
}

class _MuscleMaxAppState extends State<MuscleMaxApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeApp(),
      builder: (context, snapshot) {
        // Show loading screen while initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Show error if initialization failed
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: Text('Error initializing app: ${snapshot.error}'),
              ),
            ),
          );
        }

        // App initialized successfully
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
            ChangeNotifierProxyProvider<UserProvider, ProfileStatsProvider>(
              create: (context) => ProfileStatsProvider(),
              update: (context, userProvider, profileStatsProvider) {
                if (userProvider.user != null) {
                  profileStatsProvider!.setUser(userProvider.user!);
                }
                return profileStatsProvider!;
              },
            ),
            ChangeNotifierProvider(create: (_) => WorkoutProvider()),
            ChangeNotifierProvider(create: (_) => NutritionProvider()..loadNutritionData()),
            ChangeNotifierProvider(create: (_) => CommunityProvider()),
            ChangeNotifierProvider(create: (_) => FriendsProvider()),
            ChangeNotifierProvider(create: (_) => BodyMeasurementProvider()..loadData()),
            ChangeNotifierProvider(create: (_) => GamificationProvider()..loadData()),
            ChangeNotifierProvider(create: (_) => SocialProvider()..loadData()),
            ChangeNotifierProvider(create: (_) => AIWorkoutProvider()),
            ChangeNotifierProxyProvider<CommunityProvider, CustomWorkoutProvider>(
              create: (context) => CustomWorkoutProvider()..loadWorkouts(),
              update: (context, communityProvider, customWorkoutProvider) {
                customWorkoutProvider!.setCommunityProvider(communityProvider);
                return customWorkoutProvider;
              },
            ),
          ],
          child: MaterialApp.router(
            title: 'MuscleMax',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: AppRoutes.router,
          ),
        );
      },
    );
  }
}
