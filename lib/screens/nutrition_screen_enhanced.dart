import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_navigation.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';
import '../screens/ai_chat_screen.dart';
import 'add_meal_screen.dart';
import 'food_scanner_screen.dart';
import 'nutrition_history_screen.dart';

class NutritionScreenEnhanced extends StatefulWidget {
  const NutritionScreenEnhanced({super.key});

  @override
  State<NutritionScreenEnhanced> createState() => _NutritionScreenEnhancedState();
}

class _NutritionScreenEnhancedState extends State<NutritionScreenEnhanced> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAIChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      bottomNavigationBar: const BottomNavigation(currentIndex: 4),
      body: Consumer<NutritionProvider>(
        builder: (context, provider, _) {
          final nutrition = provider.todayNutrition;
          
          if (nutrition == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with image background
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.backgroundCard,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/home'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/nutrition_tab_background.png'),
                        fit: BoxFit.cover,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'NUTRITION',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'BebasNeue',
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        blurRadius: 20,
                                        offset: const Offset(0, 2),
                                      ),
                                      Shadow(
                                        color: AppColors.primaryRed.withOpacity(0.5),
                                        blurRadius: 30,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.history, color: Colors.white, shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 8,
                                    ),
                                  ]),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const NutritionHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('EEEE, MMMM d').format(nutrition.date),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 10,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Calorie Summary Card
                    _buildCalorieSummaryCard(nutrition),
                    
                    const SizedBox(height: 20),
                    
                    // Macros Breakdown
                    _buildMacrosBreakdown(nutrition),
                    
                    const SizedBox(height: 20),
                    
                    // Water Tracker
                    _buildWaterTracker(nutrition, provider),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Actions
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 20),
                    
                    // Meals Section
                    _buildMealsSection(nutrition, provider),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'ai_chat',
            onPressed: _showAIChat,
            backgroundColor: AppColors.primaryRed,
            child: const Icon(Icons.psychology, size: 24),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'add_meal',
            onPressed: () => _showAddMealOptions(context),
            backgroundColor: AppColors.primaryRed,
            icon: const Icon(Icons.add),
            label: const Text('LOG MEAL'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieSummaryCard(DailyNutrition nutrition) {
    final remaining = nutrition.goals.calorieGoal - nutrition.totalCalories;
    final progress = nutrition.caloriesProgress.clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundCard,
              AppColors.backgroundCard.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONSUMED',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nutrition.totalCalories.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'calories',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: AppColors.backgroundDark,
                        valueColor: AlwaysStoppedAnimation(
                          progress > 1.0 ? Colors.orange : AppColors.primaryRed,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'of goal',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: remaining >= 0 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remaining >= 0 ? 'Remaining' : 'Over Goal',
                    style: TextStyle(
                      color: remaining >= 0 ? Colors.green : Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${remaining.abs().toInt()} kcal',
                    style: TextStyle(
                      color: remaining >= 0 ? Colors.green : Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildMacrosBreakdown(DailyNutrition nutrition) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MACROS BREAKDOWN',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  'Protein',
                  nutrition.totalProtein,
                  nutrition.goals.proteinGoal,
                  'g',
                  Colors.blue,
                  Icons.egg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  'Carbs',
                  nutrition.totalCarbs,
                  nutrition.goals.carbsGoal,
                  'g',
                  Colors.orange,
                  Icons.bakery_dining,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroCard(
                  'Fat',
                  nutrition.totalFat,
                  nutrition.goals.fatGoal,
                  'g',
                  Colors.purple,
                  Icons.water_drop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String name, double current, double goal, String unit, Color color, IconData icon) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${current.toInt()}',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/ ${goal.toInt()}$unit',
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundDark,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker(DailyNutrition nutrition, NutritionProvider provider) {
    final cups = (nutrition.waterIntake / 250).floor();
    final progress = nutrition.waterProgress.clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.withOpacity(0.2),
              Colors.blue.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.lightBlue, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WATER INTAKE',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${nutrition.waterIntake}ml / ${nutrition.goals.waterGoal}ml',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '$cups 🥤',
                  style: const TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.backgroundDark,
                valueColor: const AlwaysStoppedAnimation(Colors.lightBlue),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.addWaterIntake(250),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.withOpacity(0.2),
                      foregroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('250ml'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.addWaterIntake(500),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.withOpacity(0.2),
                      foregroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('500ml'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Scan Food',
              Icons.camera_alt,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodScannerScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Add Manual',
              Icons.edit,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMealScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsSection(DailyNutrition nutrition, NutritionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY\'S MEALS',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildMealTypeSection('Breakfast', 'breakfast', provider),
          const SizedBox(height: 12),
          _buildMealTypeSection('Lunch', 'lunch', provider),
          const SizedBox(height: 12),
          _buildMealTypeSection('Dinner', 'dinner', provider),
          const SizedBox(height: 12),
          _buildMealTypeSection('Snacks', 'snack', provider),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(String title, String type, NutritionProvider provider) {
    final meals = provider.getMealsByType(type);
    final totalCals = meals.fold<double>(0, (sum, m) => sum + m.totalCalories);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textGray.withOpacity(0.2)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMealTypeColor(type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMealTypeIcon(type),
                  color: _getMealTypeColor(type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      meals.isEmpty ? 'No meals' : '${meals.length} meal(s)',
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (totalCals > 0)
                Text(
                  '${totalCals.toInt()} kcal',
                  style: TextStyle(
                    color: _getMealTypeColor(type),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          children: [
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _showAddMealOptions(context, type),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text('Add $title'),
                  ),
                ),
              )
            else
              ...meals.map((meal) => _buildMealItem(meal, provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Meal meal, NutritionProvider provider) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.removeMeal(meal.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meal.name,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(meal.dateTime),
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientTag('${meal.totalCalories.toInt()} kcal', Colors.red),
                _buildNutrientTag('P: ${meal.totalProtein.toInt()}g', Colors.blue),
                _buildNutrientTag('C: ${meal.totalCarbs.toInt()}g', Colors.orange),
                _buildNutrientTag('F: ${meal.totalFat.toInt()}g', Colors.purple),
              ],
            ),
            if (meal.foods.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: AppColors.textGray, height: 1),
              const SizedBox(height: 8),
              ...meal.foods.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${entry.food.name} (${entry.servings}x)',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 13,
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealTypeColor(String type) {
    switch (type) {
      case 'breakfast':
        return Colors.amber;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.deepPurple;
      case 'snack':
        return Colors.pink;
      default:
        return AppColors.primaryRed;
    }
  }

  void _showAddMealOptions(BuildContext context, [String? mealType]) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Meal',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.purple),
              ),
              title: const Text(
                'Scan Food with Camera',
                style: TextStyle(color: AppColors.textWhite),
              ),
              subtitle: const Text(
                'AI-powered food recognition',
                style: TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodScannerScreen(mealType: mealType),
                  ),
                );
              },
            ),
            const Divider(color: AppColors.textGray),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_circle, color: Colors.green),
              ),
              title: const Text(
                'Add Manually',
                style: TextStyle(color: AppColors.textWhite),
              ),
              subtitle: const Text(
                'Search from food database',
                style: TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealScreen(mealType: mealType),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
