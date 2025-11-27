import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final userProvider = context.read<UserProvider>();
        
        // Load existing user from storage
        await userProvider.loadUser();
        
        if (mounted) {
          // Check if user exists
          if (!userProvider.isAuthenticated) {
            // No user found in storage
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No account found. Please register first.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          // Verify email matches (simple local auth without password check)
          final storedUser = userProvider.user!;
          if (storedUser.email.toLowerCase() != _emailController.text.trim().toLowerCase()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid email. Please use the email you registered with.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          // Email matches - check profile completion
          if (!userProvider.isProfileComplete) {
            // User exists but profile incomplete - go to profile setup
            context.go(AppRoutes.profileSetup);
          } else {
            // User exists and profile complete - go to home
            context.go(AppRoutes.home);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential == null) {
        // User canceled the sign-in
        return;
      }

      final firebaseUser = userCredential.user!;
      final userProvider = context.read<UserProvider>();
      
      // Check if user exists in local storage
      await userProvider.loadUser();
      
      if (mounted) {
        if (userProvider.user == null || userProvider.user!.email != firebaseUser.email) {
          // New user - create profile
          final newUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            fullName: firebaseUser.displayName ?? '',
            profilePhoto: firebaseUser.photoURL,
          );
          
          await userProvider.saveUser(newUser);
          
          // Navigate to profile setup
          context.go(AppRoutes.profileSetup);
        } else {
          // Existing user
          if (!userProvider.isProfileComplete) {
            context.go(AppRoutes.profileSetup);
          } else {
            context.go(AppRoutes.home);
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${firebaseUser.displayName ?? 'User'}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(AppRoutes.onboarding),
                  ),
                  const SizedBox(height: 24),
                  
                  // Heading
                  Text(
                    'Welcome to MUSCLEMAX',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subheading
                  Text(
                    'Hello there, sign-in\nto continue!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Email field
                  CustomTextField(
                    label: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Password field
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Login button
                  CustomButton(
                    text: 'Login',
                    onPressed: () => _login(),
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Or login with
                  Center(
                    child: Text(
                      'Or Login with',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Social buttons
                  SocialButton(
                    text: 'Connect with Google',
                    icon: Icons.g_mobiledata,
                    backgroundColor: Colors.white,
                    textColor: AppColors.textDarkGray,
                    onPressed: _isGoogleLoading ? () {} : () => _signInWithGoogle(),
                  ),
                  const SizedBox(height: 12),
                  SocialButton(
                    text: 'Connect With Facebook',
                    icon: Icons.facebook,
                    backgroundColor: const Color(0xFF1877F2),
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 32),
                  
                  // Register link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.register),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: const [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Register!',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
