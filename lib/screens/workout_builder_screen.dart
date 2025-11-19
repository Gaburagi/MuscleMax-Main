import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/custom_workout_provider.dart';
import '../models/custom_workout_model.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'strength';
  final List<WorkoutExercise> _selectedExercises = [];
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise(ExerciseTemplate template) {
    setState(() {
      _selectedExercises.add(WorkoutExercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        template: template,
        sets: [
          CustomExerciseSet(reps: 10, weight: 0, duration: 0),
          CustomExerciseSet(reps: 10, weight: 0, duration: 0),
          CustomExerciseSet(reps: 10, weight: 0, duration: 0),
        ],
        restTime: 60,
        orderIndex: _selectedExercises.length,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
      // Update order indices
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i] = WorkoutExercise(
          id: _selectedExercises[i].id,
          template: _selectedExercises[i].template,
          sets: _selectedExercises[i].sets,
          restTime: _selectedExercises[i].restTime,
          notes: _selectedExercises[i].notes,
          isSuperset: _selectedExercises[i].isSuperset,
          orderIndex: i,
        );
      }
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, exercise);
      // Update order indices
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i] = WorkoutExercise(
          id: _selectedExercises[i].id,
          template: _selectedExercises[i].template,
          sets: _selectedExercises[i].sets,
          restTime: _selectedExercises[i].restTime,
          notes: _selectedExercises[i].notes,
          isSuperset: _selectedExercises[i].isSuperset,
          orderIndex: i,
        );
      }
    });
  }

  void _updateExerciseSets(int exerciseIndex, int setsCount) {
    setState(() {
      final exercise = _selectedExercises[exerciseIndex];
      final currentSets = exercise.sets;
      
      List<CustomExerciseSet> newSets;
      if (setsCount > currentSets.length) {
        // Add more sets
        newSets = List.from(currentSets);
        for (int i = currentSets.length; i < setsCount; i++) {
          newSets.add(CustomExerciseSet(
            reps: currentSets.isNotEmpty ? currentSets.last.reps : 10,
            weight: currentSets.isNotEmpty ? currentSets.last.weight : 0,
            duration: currentSets.isNotEmpty ? currentSets.last.duration : 0,
          ));
        }
      } else {
        // Remove sets
        newSets = currentSets.sublist(0, setsCount);
      }
      
      _selectedExercises[exerciseIndex] = WorkoutExercise(
        id: exercise.id,
        template: exercise.template,
        sets: newSets,
        restTime: exercise.restTime,
        notes: exercise.notes,
        isSuperset: exercise.isSuperset,
        orderIndex: exercise.orderIndex,
      );
    });
  }

  void _updateRestTime(int exerciseIndex, int seconds) {
    setState(() {
      final exercise = _selectedExercises[exerciseIndex];
      _selectedExercises[exerciseIndex] = WorkoutExercise(
        id: exercise.id,
        template: exercise.template,
        sets: exercise.sets,
        restTime: seconds,
        notes: exercise.notes,
        isSuperset: exercise.isSuperset,
        orderIndex: exercise.orderIndex,
      );
    });
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate() && _selectedExercises.isNotEmpty) {
      final provider = context.read<CustomWorkoutProvider>();
      
      final workout = CustomWorkout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        exercises: _selectedExercises,
        category: _selectedCategory,
        estimatedDuration: _selectedExercises.length * 10,
        createdAt: DateTime.now(),
      );
      
      await provider.addCustomWorkout(workout);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully!')),
        );
        context.pop();
      }
    } else if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
    }
  }

  void _showExerciseLibrary() {
    final provider = context.read<CustomWorkoutProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EXERCISE LIBRARY',
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.exerciseTemplates.length,
                itemBuilder: (context, index) {
                  final exercise = provider.exerciseTemplates[index];
                  return _buildExerciseLibraryCard(exercise);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseLibraryCard(ExerciseTemplate exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getExerciseIcon(exercise.category),
              color: AppColors.primaryRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.muscleGroup,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _addExercise(exercise);
            },
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'CREATE WORKOUT',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveWorkout,
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 16,
                color: AppColors.primaryRed,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Workout Name
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Workout Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: const Color(0xFF333333),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'strength', child: Text('Strength')),
                DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                DropdownMenuItem(value: 'flexibility', child: Text('Flexibility')),
                DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 24),
            
            // Exercises Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EXERCISES',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showExerciseLibrary,
                  icon: const Icon(Icons.add, color: AppColors.primaryRed),
                  label: const Text(
                    'ADD EXERCISE',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Exercise List
            if (_selectedExercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No exercises added yet',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedExercises.length,
                onReorder: _reorderExercises,
                itemBuilder: (context, index) {
                  final exercise = _selectedExercises[index];
                  return _buildExerciseCard(exercise, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int index) {
    return Container(
      key: ValueKey(exercise.template.id + index.toString()),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.drag_handle,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.template.name,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _removeExercise(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Sets and Rest Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sets',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          color: Colors.white,
                          onPressed: exercise.sets.length > 1
                              ? () => _updateExerciseSets(index, exercise.sets.length - 1)
                              : null,
                        ),
                        Text(
                          '${exercise.sets.length}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          color: Colors.white,
                          onPressed: () => _updateExerciseSets(index, exercise.sets.length + 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest Time (sec)',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          color: Colors.white,
                          onPressed: exercise.restTime > 15
                              ? () => _updateRestTime(index, exercise.restTime - 15)
                              : null,
                        ),
                        Text(
                          '${exercise.restTime}s',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          color: Colors.white,
                          onPressed: () => _updateRestTime(index, exercise.restTime + 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
