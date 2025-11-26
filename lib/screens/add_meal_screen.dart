import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_colors.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';

class AddMealScreen extends StatefulWidget {
  final String? mealType;
  
  const AddMealScreen({super.key, this.mealType});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mealNameController = TextEditingController();
  String _selectedMealType = 'breakfast';
  final List<FoodEntry> _selectedFoods = [];
  List<Food> _searchResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.mealType != null) {
      _selectedMealType = widget.mealType!;
    }
    _searchResults = context.read<NutritionProvider>().commonFoods;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mealNameController.dispose();
    super.dispose();
  }

  void _searchFoods(String query) {
    final provider = context.read<NutritionProvider>();
    setState(() {
      if (query.isEmpty) {
        _searchResults = provider.commonFoods;
      } else {
        _searchResults = provider.commonFoods
            .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addFood(Food food) {
    showDialog(
      context: context,
      builder: (context) => _ServingSizeDialog(
        food: food,
        onAdd: (servings) {
          setState(() {
            _selectedFoods.add(FoodEntry(food: food, servings: servings));
          });
        },
      ),
    );
  }

  void _saveMeal() {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one food item')),
      );
      return;
    }

    final mealName = _mealNameController.text.trim().isEmpty
        ? '${_selectedMealType[0].toUpperCase()}${_selectedMealType.substring(1)}'
        : _mealNameController.text.trim();

    final meal = Meal(
      id: const Uuid().v4(),
      name: mealName,
      type: _selectedMealType,
      dateTime: DateTime.now(),
      foods: _selectedFoods,
    );

    context.read<NutritionProvider>().addMeal(meal);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$mealName added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _selectedFoods.fold<double>(0, (sum, entry) => sum + entry.calories);
    final totalProtein = _selectedFoods.fold<double>(0, (sum, entry) => sum + entry.protein);
    final totalCarbs = _selectedFoods.fold<double>(0, (sum, entry) => sum + entry.carbs);
    final totalFat = _selectedFoods.fold<double>(0, (sum, entry) => sum + entry.fat);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Add Meal'),
        actions: [
          TextButton(
            onPressed: _saveMeal,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          if (_selectedFoods.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.2),
                    Colors.pink.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MEAL TOTALS',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${totalCalories.toInt()} kcal',
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroChip('P: ${totalProtein.toInt()}g', Colors.blue),
                      _buildMacroChip('C: ${totalCarbs.toInt()}g', Colors.orange),
                      _buildMacroChip('F: ${totalFat.toInt()}g', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),

          // Meal Name Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _mealNameController,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                labelText: 'Meal Name (Optional)',
                labelStyle: const TextStyle(color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Meal Type Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildMealTypeChip('breakfast', 'Breakfast', Icons.free_breakfast),
                const SizedBox(width: 8),
                _buildMealTypeChip('lunch', 'Lunch', Icons.lunch_dining),
                const SizedBox(width: 8),
                _buildMealTypeChip('dinner', 'Dinner', Icons.dinner_dining),
                const SizedBox(width: 8),
                _buildMealTypeChip('snack', 'Snack', Icons.fastfood),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchFoods,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: const TextStyle(color: AppColors.textGray),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selected Foods List
          if (_selectedFoods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SELECTED FOODS',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedFoods.clear()),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedFoods.length,
                itemBuilder: (context, index) {
                  final entry = _selectedFoods[index];
                  return _buildSelectedFoodCard(entry, index);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Available Foods List
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AVAILABLE FOODS',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final food = _searchResults[index];
                return _buildFoodListItem(food);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedMealType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMealType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textGray,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textGray,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelectedFoodCard(FoodEntry entry, int index) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.food.name,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _selectedFoods.removeAt(index)),
                child: const Icon(Icons.close, color: Colors.red, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${entry.servings}x serving',
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.calories.toInt()} kcal',
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodListItem(Food food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          food.name,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${food.calories.toInt()} kcal • P: ${food.protein.toInt()}g C: ${food.carbs.toInt()}g F: ${food.fat.toInt()}g',
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.primaryRed),
          onPressed: () => _addFood(food),
        ),
      ),
    );
  }
}

class _ServingSizeDialog extends StatefulWidget {
  final Food food;
  final Function(double) onAdd;

  const _ServingSizeDialog({required this.food, required this.onAdd});

  @override
  State<_ServingSizeDialog> createState() => _ServingSizeDialogState();
}

class _ServingSizeDialogState extends State<_ServingSizeDialog> {
  double _servings = 1.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Text(
        widget.food.name,
        style: const TextStyle(color: AppColors.textWhite),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How many servings?',
            style: const TextStyle(color: AppColors.textGray),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: AppColors.primaryRed),
                onPressed: () {
                  if (_servings > 0.25) {
                    setState(() => _servings -= 0.25);
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _servings.toStringAsFixed(2),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primaryRed),
                onPressed: () => setState(() => _servings += 0.25),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${(widget.food.calories * _servings).toInt()} kcal',
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'P: ${(widget.food.protein * _servings).toInt()}g • '
                  'C: ${(widget.food.carbs * _servings).toInt()}g • '
                  'F: ${(widget.food.fat * _servings).toInt()}g',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(_servings);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
          ),
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
