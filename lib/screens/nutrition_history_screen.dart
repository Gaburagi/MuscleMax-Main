import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';
import '../providers/nutrition_provider.dart';
import '../models/nutrition_model.dart';

class NutritionHistoryScreen extends StatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  String _selectedView = 'week'; // week, month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Nutrition History'),
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // View Selector
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildViewButton('Week', 'week'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildViewButton('Month', 'month'),
                      ),
                    ],
                  ),
                ),

                // Calorie Chart
                _buildCalorieChart(provider),

                const SizedBox(height: 24),

                // Macros Chart
                _buildMacrosChart(provider),

                const SizedBox(height: 24),

                // Statistics
                _buildStatistics(provider),

                const SizedBox(height: 24),

                // Recent Days
                _buildRecentDays(provider),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewButton(String label, String value) {
    final isSelected = _selectedView == value;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedView = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
        foregroundColor: isSelected ? Colors.white : AppColors.textGray,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCalorieChart(NutritionProvider provider) {
    final days = _selectedView == 'week' ? 7 : 30;
    final data = _getChartData(provider, days);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CALORIE INTAKE',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 500,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColors.textGray.withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < data.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      data[value.toInt()]['label'],
                                      style: const TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 500,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (data.length - 1).toDouble(),
                        minY: 0,
                        maxY: 3000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value['calories'],
                              );
                            }).toList(),
                            isCurved: true,
                            color: AppColors.primaryRed,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryRed.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosChart(NutritionProvider provider) {
    final days = _selectedView == 'week' ? 7 : 30;
    final avgMacros = _getAverageMacros(provider, days);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AVERAGE MACROS',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroCircle(
                  'Protein',
                  avgMacros['protein']!.toInt(),
                  Colors.blue,
                ),
                _buildMacroCircle(
                  'Carbs',
                  avgMacros['carbs']!.toInt(),
                  Colors.orange,
                ),
                _buildMacroCircle(
                  'Fat',
                  avgMacros['fat']!.toInt(),
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCircle(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              '${value}g',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(NutritionProvider provider) {
    final days = _selectedView == 'week' ? 7 : 30;
    final stats = _getStatistics(provider, days);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STATISTICS',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Average Daily Calories', '${stats['avgCalories']} kcal'),
            const Divider(color: AppColors.textGray),
            _buildStatRow('Total Meals Logged', '${stats['totalMeals']}'),
            const Divider(color: AppColors.textGray),
            _buildStatRow('Days Tracked', '${stats['daysTracked']} / $days'),
            const Divider(color: AppColors.textGray),
            _buildStatRow('Average Water', '${stats['avgWater']} ml'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDays(NutritionProvider provider) {
    final history = provider.nutritionHistory;
    final sortedDates = history.keys.toList()..sort((a, b) => b.compareTo(a));
    final recentDates = sortedDates.take(7).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT DAYS',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recentDates.map((dateKey) {
            final nutrition = history[dateKey]!;
            final date = nutrition.date;
            return _buildDayCard(date, nutrition);
          }),
        ],
      ),
    );
  }

  Widget _buildDayCard(DateTime date, DailyNutrition nutrition) {
    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.primaryRed, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToday ? 'Today' : DateFormat('EEEE, MMM d').format(date),
                style: TextStyle(
                  color: isToday ? AppColors.primaryRed : AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${nutrition.totalCalories.toInt()} kcal',
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSmallMacroChip(
                'P: ${nutrition.totalProtein.toInt()}g',
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildSmallMacroChip(
                'C: ${nutrition.totalCarbs.toInt()}g',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildSmallMacroChip(
                'F: ${nutrition.totalFat.toInt()}g',
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${nutrition.meals.length} meals • ${nutrition.waterIntake}ml water',
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData(NutritionProvider provider, int days) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final nutrition = provider.nutritionHistory[dateKey];
      
      data.add({
        'label': DateFormat('E').format(date).substring(0, 1),
        'calories': nutrition?.totalCalories ?? 0.0,
      });
    }

    return data;
  }

  Map<String, double> _getAverageMacros(NutritionProvider provider, int days) {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    int count = 0;

    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final nutrition = provider.nutritionHistory[dateKey];
      
      if (nutrition != null && nutrition.meals.isNotEmpty) {
        totalProtein += nutrition.totalProtein;
        totalCarbs += nutrition.totalCarbs;
        totalFat += nutrition.totalFat;
        count++;
      }
    }

    return {
      'protein': count > 0 ? totalProtein / count : 0,
      'carbs': count > 0 ? totalCarbs / count : 0,
      'fat': count > 0 ? totalFat / count : 0,
    };
  }

  Map<String, int> _getStatistics(NutritionProvider provider, int days) {
    double totalCalories = 0;
    int totalMeals = 0;
    int daysTracked = 0;
    int totalWater = 0;

    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final nutrition = provider.nutritionHistory[dateKey];
      
      if (nutrition != null) {
        if (nutrition.meals.isNotEmpty) {
          daysTracked++;
          totalMeals += nutrition.meals.length;
        }
        totalCalories += nutrition.totalCalories;
        totalWater += nutrition.waterIntake;
      }
    }

    return {
      'avgCalories': daysTracked > 0 ? (totalCalories / daysTracked).round() : 0,
      'totalMeals': totalMeals,
      'daysTracked': daysTracked,
      'avgWater': daysTracked > 0 ? (totalWater / daysTracked).round() : 0,
    };
  }
}
