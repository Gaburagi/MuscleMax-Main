import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/ai_models.dart';
import '../providers/ai_workout_provider.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import 'active_ai_workout_screen.dart';

class QuickWorkoutGeneratorScreen extends StatefulWidget {
  const QuickWorkoutGeneratorScreen({super.key});

  @override
  State<QuickWorkoutGeneratorScreen> createState() => _QuickWorkoutGeneratorScreenState();
}

class _QuickWorkoutGeneratorScreenState extends State<QuickWorkoutGeneratorScreen> {
  int _availableMinutes = 45;
  WorkoutIntensity _intensity = WorkoutIntensity.moderate;
  String _goal = 'general_fitness';
  final List<String> _selectedMuscles = [];
  final List<String> _selectedEquipment = [];
  bool _isGenerating = false;

  final List<String> _allMuscles = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
  final List<String> _allEquipment = ['bodyweight', 'dumbbells', 'barbell', 'machine', 'cable machine', 'pull-up bar'];
  final Map<String, String> _goals = {
    'strength': 'Build Strength',
    'hypertrophy': 'Build Muscle',
    'endurance': 'Improve Endurance',
    'weight_loss': 'Lose Weight',
    'general_fitness': 'General Fitness',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          'QUICK WORKOUT AI',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isGenerating
          ? _buildGeneratingView()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTimeSelector(),
                const SizedBox(height: 24),
                _buildIntensitySelector(),
                const SizedBox(height: 24),
                _buildGoalSelector(),
                const SizedBox(height: 24),
                _buildMuscleSelector(),
                const SizedBox(height: 24),
                _buildEquipmentSelector(),
                const SizedBox(height: 32),
                _buildGenerateButton(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryRed.withOpacity(0.2),
                AppColors.primaryRedDark.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Workouts',
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Get a personalized workout in seconds',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AVAILABLE TIME',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_availableMinutes minutes',
                    style: const TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 32,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  Text(
                    '~${(_availableMinutes * 6).round()} cal',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _availableMinutes.toDouble(),
                min: 30,
                max: 120,
                divisions: 18,
                activeColor: AppColors.primaryRed,
                inactiveColor: Colors.white24,
                label: '$_availableMinutes min',
                onChanged: (value) {
                  setState(() {
                    _availableMinutes = value.round();
                  });
                },
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('30 min', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                  Text('2 hrs', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INTENSITY LEVEL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildIntensityChip(WorkoutIntensity.light, 'Light', Icons.spa),
            const SizedBox(width: 8),
            _buildIntensityChip(WorkoutIntensity.moderate, 'Moderate', Icons.trending_up),
            const SizedBox(width: 8),
            _buildIntensityChip(WorkoutIntensity.hard, 'Hard', Icons.whatshot),
            const SizedBox(width: 8),
            _buildIntensityChip(WorkoutIntensity.extreme, 'Extreme', Icons.flash_on),
          ],
        ),
      ],
    );
  }

  Widget _buildIntensityChip(WorkoutIntensity intensity, String label, IconData icon) {
    final isSelected = _intensity == intensity;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _intensity = intensity),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryRed : Colors.white24,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FITNESS GOAL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goals.entries.map((entry) {
            final isSelected = _goal == entry.key;
            return GestureDetector(
              onTap: () => setState(() => _goal = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryRed : Colors.white24,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMuscleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TARGET MUSCLES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (_selectedMuscles.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selectedMuscles.clear()),
                child: const Text('Clear', style: TextStyle(color: AppColors.primaryRed)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedMuscles.isEmpty ? 'Leave empty for full body workout' : '${_selectedMuscles.length} selected',
          style: const TextStyle(color: AppColors.textGray, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allMuscles.map((muscle) {
            final isSelected = _selectedMuscles.contains(muscle);
            return FilterChip(
              label: Text(muscle),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedMuscles.add(muscle);
                  } else {
                    _selectedMuscles.remove(muscle);
                  }
                });
              },
              selectedColor: AppColors.primaryRed,
              backgroundColor: AppColors.backgroundCard,
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AVAILABLE EQUIPMENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (_selectedEquipment.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selectedEquipment.clear()),
                child: const Text('Clear', style: TextStyle(color: AppColors.primaryRed)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _selectedEquipment.isEmpty ? 'Leave empty for any equipment' : '${_selectedEquipment.length} selected',
          style: const TextStyle(color: AppColors.textGray, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allEquipment.map((equipment) {
            final isSelected = _selectedEquipment.contains(equipment);
            return FilterChip(
              label: Text(equipment),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(equipment);
                  } else {
                    _selectedEquipment.remove(equipment);
                  }
                });
              },
              selectedColor: AppColors.primaryRed,
              backgroundColor: AppColors.backgroundCard,
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _generateWorkout,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 24),
          SizedBox(width: 12),
          Text(
            'GENERATE WORKOUT',
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing progress indicator
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (0.1 * (value > 0.5 ? 1 - value : value) * 2),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryRed.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primaryRed,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI is crafting your perfect workout...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Animated dots
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: 3),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Text(
                  'Analyzing your preferences${'.' * (value % 4)}',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateWorkout() async {
    final aiProvider = context.read<AIWorkoutProvider>();
    
    // Check recovery status before generating
    final recoveryStatus = aiProvider.getMuscleGroupRecoveryStatus();
    final fatiguedMuscles = <String>[];
    
    if (_selectedMuscles.isNotEmpty) {
      for (final muscle in _selectedMuscles) {
        final status = recoveryStatus.firstWhere(
          (s) => s.muscleGroup == muscle,
          orElse: () => MuscleGroupRecovery(
            muscleGroup: muscle,
            fatigueLevel: 0,
            lastWorked: DateTime.now(),
            hoursUntilRecovered: 0,
            readyToTrain: true,
            recommendation: 'Ready',
            workoutsThisWeek: 0,
            weeklyVolumeLoad: 0,
          ),
        );
        
        if (status.fatigueLevel > 70) {
          fatiguedMuscles.add(muscle);
        }
      }
    }
    
    // Show warning if fatigued muscles selected
    if (fatiguedMuscles.isNotEmpty && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Recovery Warning',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The following muscle groups are still fatigued:',
                style: const TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...fatiguedMuscles.map((muscle) {
                final status = recoveryStatus.firstWhere((s) => s.muscleGroup == muscle);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$muscle (${status.fatigueLevel.toInt()}% fatigue)',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Text(
                  '💡 Tip: Training fatigued muscles may increase injury risk. Consider choosing different muscle groups or reducing intensity.',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.textGray)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('CONTINUE ANYWAY', style: TextStyle(color: AppColors.primaryRed)),
            ),
          ],
        ),
      );
      
      if (proceed != true) return;
    }
    
    setState(() => _isGenerating = true);
    
    final request = WorkoutGenerationRequest(
      availableMinutes: _availableMinutes,
      intensity: _intensity,
      targetMuscleGroups: _selectedMuscles,
      availableEquipment: _selectedEquipment,
      goal: _goal,
      fitnessLevel: 5, // Could be pulled from user profile
    );

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    final workout = await aiProvider.generateQuickWorkout(request);

    setState(() => _isGenerating = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveAIWorkoutScreen(workout: workout),
        ),
      );
    }
  }
}
