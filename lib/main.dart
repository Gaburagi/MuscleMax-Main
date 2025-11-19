import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/routes.dart';
import 'providers/user_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/custom_workout_provider.dart';
import 'providers/community_provider.dart';
import 'providers/friends_provider.dart';
import 'providers/body_measurement_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MuscleMaxApp());
}

class MuscleMaxApp extends StatefulWidget {
  const MuscleMaxApp({super.key});

  @override
  State<MuscleMaxApp> createState() => _MuscleMaxAppState();
}

class _MuscleMaxAppState extends State<MuscleMaxApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()..loadNutritionData()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => BodyMeasurementProvider()..loadData()),
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
  }
}
