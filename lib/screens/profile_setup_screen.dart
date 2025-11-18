import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/user_provider.dart';
import '../utils/routes.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Age
  String _age = '';
  
  // Step 2: Gender
  String? _selectedGender;
  
  // Step 3: Height
  String _height = '175';
  bool _useMetricHeight = true; // true = cm, false = inches
  
  // Step 4: Weight
  String _weight = '85';
  bool _useMetricWeight = true; // true = kg, false = lbs
  
  // Step 5: Fitness Goal
  String? _selectedGoal;
  
  // Step 6: Exercise Preferences
  final List<String> _selectedExercises = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _skipToEnd() {
    context.go(AppRoutes.home);
  }

  Future<void> _saveProfile() async {
    if (_age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your age')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fitness goal')),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert height and weight to metric if needed
      double heightInCm = _useMetricHeight 
          ? double.parse(_height) 
          : double.parse(_height) * 2.54;
      double weightInKg = _useMetricWeight 
          ? double.parse(_weight) 
          : double.parse(_weight) * 0.453592;

      final userProvider = context.read<UserProvider>();
      await userProvider.updateProfile(
        age: int.parse(_age),
        height: heightInCm,
        weight: weightInKg,
        fitnessGoal: _selectedGoal,
        selectedExercises: _selectedExercises,
      );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Decorative lights matching Figma
            Positioned(
              top: -150,
              left: 100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundCard.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.backgroundCard.withOpacity(0.2),
                      blurRadius: 300,
                      spreadRadius: 100,
                    ),
                  ],
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // Top bar with back and skip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _previousStep,
                        ),
                        TextButton(
                          onPressed: _skipToEnd,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // PageView for steps
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() => _currentStep = index),
                      children: [
                        _buildAgeStep(),
                        _buildGenderStep(),
                        _buildHeightStep(),
                        _buildWeightStep(),
                        _buildGoalStep(),
                        _buildExerciseStep(),
                      ],
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

  // Step 1: Age
  Widget _buildAgeStep() {
    return _buildNumberInputStep(
      step: 1,
      title: "WHAT's YOUR AGE?",
      value: _age,
      onValueChanged: (val) => setState(() => _age = val),
      unit: 'years',
      showUnitToggle: false,
    );
  }

  // Step 2: Gender
  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 2 of 6',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "SELECT YOUR GENDER",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              fontFamily: 'Bebas Neue',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 60),
          
          // Gender options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGenderOption('Male', Icons.male),
              _buildGenderOption('Female', Icons.female),
            ],
          ),
          
          const Spacer(),
          
          // Next button
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              gender,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Height
  Widget _buildHeightStep() {
    return _buildNumberInputStep(
      step: 3,
      title: "WHAT's YOUR HEIGHT?",
      value: _height,
      onValueChanged: (val) => setState(() => _height = val),
      unit: _useMetricHeight ? 'cm' : 'in',
      showUnitToggle: true,
      onUnitToggle: () => setState(() => _useMetricHeight = !_useMetricHeight),
    );
  }

  // Step 4: Weight
  Widget _buildWeightStep() {
    return _buildNumberInputStep(
      step: 4,
      title: "WHAT's YOUR WEIGHT?",
      value: _weight,
      onValueChanged: (val) => setState(() => _weight = val),
      unit: _useMetricWeight ? 'kg' : 'lbs',
      showUnitToggle: true,
      onUnitToggle: () => setState(() => _useMetricWeight = !_useMetricWeight),
    );
  }

  // Step 5: Fitness Goal
  Widget _buildGoalStep() {
    final goals = [
      'Build Muscle',
      'Lose Weight',
      'Stay Fit',
      'Improve Flexibility'
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 5 of 6',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "WHAT's YOUR GOAL?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              fontFamily: 'Bebas Neue',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: goals.map((goal) {
              final isSelected = _selectedGoal == goal;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    goal,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          _buildNextButton(),
        ],
      ),
    );
  }

  // Step 6: Exercise Preferences
  Widget _buildExerciseStep() {
    final exercises = ['Yoga', 'Gym', 'Cardio', 'Stretch', 'Full Body'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 6 of 6',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "EXERCISE PREFERENCES",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              fontFamily: 'Bebas Neue',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 40),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: exercises.map((exercise) {
              final isSelected = _selectedExercises.contains(exercise);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedExercises.remove(exercise);
                    } else {
                      _selectedExercises.add(exercise);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    exercise,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          _buildNextButton(),
        ],
      ),
    );
  }

  // Reusable number input step (for age, height, weight)
  Widget _buildNumberInputStep({
    required int step,
    required String title,
    required String value,
    required Function(String) onValueChanged,
    required String unit,
    bool showUnitToggle = false,
    VoidCallback? onUnitToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $step of 6',
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              fontFamily: 'Bebas Neue',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 60),
          
          // Large input display
          Center(
            child: Container(
              width: 300,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: AppColors.backgroundCard),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.isEmpty ? '0' : value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 19,
                    color: AppColors.backgroundCard,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (showUnitToggle) ...[
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'press',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onUnitToggle,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'to change unit of measurement',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const Spacer(),
          
          // Numeric keyboard
          _buildNumericKeyboard(value, onValueChanged),
          
          const SizedBox(height: 20),
          
          _buildNextButton(),
        ],
      ),
    );
  }

  // Custom numeric keyboard
  Widget _buildNumericKeyboard(String currentValue, Function(String) onValueChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Row 1-3
          _buildKeyboardRow(['1', '2', '3'], currentValue, onValueChanged),
          const SizedBox(height: 12),
          _buildKeyboardRow(['4', '5', '6'], currentValue, onValueChanged),
          const SizedBox(height: 12),
          _buildKeyboardRow(['7', '8', '9'], currentValue, onValueChanged),
          const SizedBox(height: 12),
          // Row 0 and backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // Empty space
              _buildKeyboardKey('0', currentValue, onValueChanged),
              GestureDetector(
                onTap: () {
                  if (currentValue.isNotEmpty) {
                    onValueChanged(currentValue.substring(0, currentValue.length - 1));
                  }
                },
                child: Container(
                  width: 70,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> numbers, String currentValue, Function(String) onValueChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) => _buildKeyboardKey(num, currentValue, onValueChanged)).toList(),
    );
  }

  Widget _buildKeyboardKey(String number, String currentValue, Function(String) onValueChanged) {
    return GestureDetector(
      onTap: () {
        if (currentValue.length < 3) {
          onValueChanged(currentValue + number);
        }
      },
      child: Container(
        width: 70,
        height: 50,
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Next/Complete button
  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _currentStep == 5 ? 'COMPLETE' : 'NEXT STEP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Bebas Neue',
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
