import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/training_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/workout_detail_screen.dart';
import '../screens/active_workout_screen.dart';
import '../screens/workout_summary_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/nutrition_screen.dart';
import '../screens/workout_library_screen.dart';
import '../screens/workout_builder_screen.dart';
import '../screens/workout_calendar_screen.dart';
import '../screens/active_custom_workout_screen.dart';
import '../screens/workout_history_screen.dart';
import '../screens/community_screen.dart';
import '../screens/friends_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String training = '/training';
  static const String profile = '/profile';
  static const String progress = '/progress';
  static const String nutrition = '/nutrition';
  static const String workoutDetail = '/workout-detail';
  static const String activeWorkout = '/active-workout';
  static const String workoutSummary = '/workout-summary';
  static const String workoutLibrary = '/workout-library';
  static const String workoutBuilder = '/workout-builder';
  static const String workoutCalendar = '/workout-calendar';
  static const String activeCustomWorkout = '/active-custom-workout';
  static const String workoutHistory = '/workout-history';
  static const String community = '/community';
  static const String friends = '/friends';
  
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: otpVerification,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: training,
        builder: (context, state) => const TrainingScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: nutrition,
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: workoutDetail,
        builder: (context, state) {
          final workoutId = state.uri.queryParameters['workoutId'] ?? '';
          return WorkoutDetailScreen(workoutId: workoutId);
        },
      ),
      GoRoute(
        path: activeWorkout,
        builder: (context, state) {
          final workoutId = state.uri.queryParameters['workoutId'] ?? '';
          return ActiveWorkoutScreen(workoutId: workoutId);
        },
      ),
      GoRoute(
        path: workoutSummary,
        builder: (context, state) {
          final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '0') ?? 0;
          final exercises = int.tryParse(state.uri.queryParameters['exercises'] ?? '0') ?? 0;
          return WorkoutSummaryScreen(
            durationSeconds: duration,
            exercisesCompleted: exercises,
          );
        },
      ),
      GoRoute(
        path: workoutLibrary,
        builder: (context, state) => const WorkoutLibraryScreen(),
      ),
      GoRoute(
        path: workoutBuilder,
        builder: (context, state) => const WorkoutBuilderScreen(),
      ),
      GoRoute(
        path: workoutCalendar,
        builder: (context, state) => const WorkoutCalendarScreen(),
      ),
      GoRoute(
        path: activeCustomWorkout,
        builder: (context, state) => const ActiveCustomWorkoutScreen(),
      ),
      GoRoute(
        path: workoutHistory,
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: community,
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: friends,
        builder: (context, state) => const FriendsScreen(),
      ),
    ],
  );
}
