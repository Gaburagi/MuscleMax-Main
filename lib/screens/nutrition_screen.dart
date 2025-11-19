import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<NutritionProvider>(
            builder: (context, provider, _) {
              final nutrition = provider.todayNutrition;
              
              if (nutrition == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                );
              }

              return Column(
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'NUTRITION',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontFamily: 'BebasNeue',
                      ),
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Calorie Card
                        _buildSimpleCard(
                          'CALORIES',
                          '${nutrition.totalCalories.toInt()} / ${nutrition.goals.calorieGoal.toInt()} kcal',
                          nutrition.caloriesProgress,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Water Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_drink, color: Colors.lightBlue, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Water: ${nutrition.waterIntake}ml',
                                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
                                ),
                              ),
                              IconButton(
                                onPressed: () => provider.addWaterIntake(250),
                                icon: const Icon(Icons.add_circle, color: AppColors.primaryRed, size: 32),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Meals Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MEALS',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Show simple add meal dialog
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColors.backgroundCard,
                                    title: const Text('Add Meal', style: TextStyle(color: AppColors.textWhite)),
                                    content: const Text(
                                      'Meal tracking coming soon!',
                                      style: TextStyle(color: AppColors.textWhite),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('ADD', style: TextStyle(color: AppColors.textWhite)),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Meal Cards
                        _buildMealTypeCard('Breakfast', provider.getMealsByType('breakfast'), provider),
                        const SizedBox(height: 12),
                        _buildMealTypeCard('Lunch', provider.getMealsByType('lunch'), provider),
                        const SizedBox(height: 12),
                        _buildMealTypeCard('Dinner', provider.getMealsByType('dinner'), provider),
                        const SizedBox(height: 12),
                        _buildMealTypeCard('Snacks', provider.getMealsByType('snack'), provider),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 4),
    );
  }

  Widget _buildSimpleCard(String title, String value, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.backgroundDark,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryRed),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeCard(String title, List<Meal> meals, NutritionProvider provider) {
    final totalCals = meals.fold<double>(0, (sum, m) => sum + m.totalCalories);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalCals > 0)
                Text(
                  '${totalCals.toInt()} kcal',
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meals.isEmpty ? 'No meals added' : '${meals.length} meal(s)',
            style: const TextStyle(color: AppColors.textGray, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;

  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => context.go('/home'),
          ),
          _NavItem(
            icon: Icons.fitness_center,
            label: 'Training',
            isSelected: currentIndex == 1,
            onTap: () => context.go('/training'),
          ),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'Progress',
            isSelected: currentIndex == 2,
            onTap: () => context.go('/progress'),
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => context.go('/profile'),
          ),
          _NavItem(
            icon: Icons.restaurant,
            label: 'Nutrition',
            isSelected: currentIndex == 4,
            onTap: () => context.go('/nutrition'),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isSelected ? AppColors.primaryRed : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
