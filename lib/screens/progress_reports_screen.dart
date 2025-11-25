import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/body_measurement_provider.dart';
import '../providers/workout_provider.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';

class ProgressReportsScreen extends StatefulWidget {
  const ProgressReportsScreen({super.key});

  @override
  State<ProgressReportsScreen> createState() => _ProgressReportsScreenState();
}

class _ProgressReportsScreenState extends State<ProgressReportsScreen> {
  String _selectedPeriod = 'week'; // week, month, 3months, 6months, year
  final DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.progressHub),
        ),
        title: const Text('Progress Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
            tooltip: 'Share Report',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(context),
            tooltip: 'Print/Export PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildReportContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundCard,
      child: Row(
        children: [
          const Text(
            'Report Period:',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isExpanded: true,
                  dropdownColor: AppColors.backgroundCard,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textWhite),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'week',
                      child: Text('Last 7 Days'),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text('Last 30 Days'),
                    ),
                    DropdownMenuItem(
                      value: '3months',
                      child: Text('Last 3 Months'),
                    ),
                    DropdownMenuItem(
                      value: '6months',
                      child: Text('Last 6 Months'),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text('Last Year'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    final measurementProvider = context.watch<BodyMeasurementProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    
    final startDate = _getStartDate();
    final endDate = DateTime.now();
    
    // Calculate statistics
    final stats = _calculateStatistics(
      measurementProvider,
      workoutProvider,
      startDate,
      endDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Report Header
        _buildReportHeader(startDate, endDate),
        const SizedBox(height: 24),

        // Workout Summary
        _buildSectionCard(
          title: 'Workout Summary',
          icon: Icons.fitness_center,
          children: [
            _buildStatRow('Workouts Completed', '${stats['workoutCount']}'),
            _buildStatRow('Total Duration', stats['totalDuration']),
            _buildStatRow('Total Exercises', '${stats['totalExercises']}'),
            _buildStatRow('Avg. Workout Time', stats['avgDuration']),
            _buildStatRow('Most Active Day', stats['mostActiveDay']),
            const SizedBox(height: 16),
            _buildWorkoutFrequencyChart(workoutProvider, startDate, endDate),
          ],
        ),
        const SizedBox(height: 16),

        // Personal Records
        _buildSectionCard(
          title: 'Personal Records',
          icon: Icons.emoji_events,
          children: [
            _buildStatRow('New PRs Achieved', '${stats['newPRs']}'),
            if (stats['latestPR'] != null)
              _buildHighlight(
                'Latest PR',
                stats['latestPR'],
                Colors.orange,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Workout Type Distribution
        _buildWorkoutTypePieChart(workoutProvider, startDate, endDate),
        const SizedBox(height: 16),

        // Body Measurements
        _buildSectionCard(
          title: 'Body Measurements',
          icon: Icons.monitor_weight,
          children: [
            _buildStatRow('Starting Weight', stats['startWeight']),
            _buildStatRow('Current Weight', stats['endWeight']),
            _buildWeightChange(stats['weightChange']),
            if (stats['startBodyFat'] != null)
              _buildStatRow('Starting Body Fat', stats['startBodyFat']),
            if (stats['endBodyFat'] != null)
              _buildStatRow('Current Body Fat', stats['endBodyFat']),
            if (stats['bodyFatChange'] != null)
              _buildBodyFatChange(stats['bodyFatChange']),
          ],
        ),
        const SizedBox(height: 16),

        // Goals Progress
        _buildSectionCard(
          title: 'Goals Progress',
          icon: Icons.flag,
          children: [
            _buildStatRow('Active Goals', '${stats['activeGoals']}'),
            _buildStatRow('Completed Goals', '${stats['completedGoals']}'),
            if (stats['goalProgress'] != null)
              _buildProgressIndicator(
                'Overall Progress',
                stats['goalProgress'],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress Photos
        _buildSectionCard(
          title: 'Progress Photos',
          icon: Icons.photo_library,
          children: [
            _buildStatRow('Photos Added', '${stats['photosAdded']}'),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutFrequencyChart(WorkoutProvider workoutProvider, DateTime startDate, DateTime endDate) {
    final workoutHistory = workoutProvider.workoutHistory
        .where((w) => w.endTime != null && 
              w.endTime!.isAfter(startDate) && 
              w.endTime!.isBefore(endDate))
        .toList();

    if (workoutHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Count workouts by day of week
    final dayCount = <String, int>{
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var workout in workoutHistory) {
      if (workout.endTime != null) {
        final day = DateFormat('E').format(workout.endTime!);
        dayCount[day] = (dayCount[day] ?? 0) + 1;
      }
    }

    final maxCount = dayCount.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxCount.toDouble() + 1,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: AppColors.textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min) return const Text('');
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: List.generate(7, (index) {
                final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                final count = dayCount[day] ?? 0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryRed,
                          AppColors.primaryRed.withOpacity(0.7),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTypePieChart(WorkoutProvider workoutProvider, DateTime startDate, DateTime endDate) {
    final workoutHistory = workoutProvider.workoutHistory
        .where((w) => w.endTime != null && 
              w.endTime!.isAfter(startDate) && 
              w.endTime!.isBefore(endDate))
        .toList();

    if (workoutHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = workoutHistory.length;
    
    // Categorize by duration
    final shortWorkouts = workoutHistory.where((w) {
      final dur = w.duration;
      return dur != null && dur.inMinutes < 30;
    }).length;

    final mediumWorkouts = workoutHistory.where((w) {
      final dur = w.duration;
      return dur != null && dur.inMinutes >= 30 && dur.inMinutes < 60;
    }).length;

    final longWorkouts = workoutHistory.where((w) {
      final dur = w.duration;
      return dur != null && dur.inMinutes >= 60;
    }).length;

    final colors = [
      Colors.green,
      AppColors.primaryRed,
      Colors.purple,
    ];

    final sections = [
      if (shortWorkouts > 0)
        PieChartSectionData(
          value: shortWorkouts.toDouble(),
          title: '${(shortWorkouts / total * 100).toInt()}%',
          color: colors[0],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (mediumWorkouts > 0)
        PieChartSectionData(
          value: mediumWorkouts.toDouble(),
          title: '${(mediumWorkouts / total * 100).toInt()}%',
          color: colors[1],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (longWorkouts > 0)
        PieChartSectionData(
          value: longWorkouts.toDouble(),
          title: '${(longWorkouts / total * 100).toInt()}%',
          color: colors[2],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final labels = [
      if (shortWorkouts > 0) {'name': 'Quick (<30 min)', 'count': shortWorkouts, 'color': colors[0]},
      if (mediumWorkouts > 0) {'name': 'Medium (30-60 min)', 'count': mediumWorkouts, 'color': colors[1]},
      if (longWorkouts > 0) {'name': 'Extended (60+ min)', 'count': longWorkouts, 'color': colors[2]},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Duration Distribution',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: labels.map((label) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: label['color'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${label['count']} workouts',
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportHeader(DateTime startDate, DateTime endDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESS REPORT',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.textWhite, size: 20),
              const SizedBox(width: 8),
              Text(
                _getPeriodLabel(),
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryRed, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChange(double? change) {
    if (change == null) {
      return _buildStatRow('Weight Change', 'N/A');
    }

    final isPositive = change > 0;
    final color = isPositive ? Colors.red : Colors.green;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Weight Change',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(
                '${change.abs().toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatChange(double? change) {
    if (change == null) {
      return _buildStatRow('Body Fat Change', 'N/A');
    }

    final isPositive = change > 0;
    final color = isPositive ? Colors.red : Colors.green;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Body Fat Change',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(
                '${change.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlight(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case 'week':
        return DateTime.now().subtract(const Duration(days: 7));
      case 'month':
        return DateTime.now().subtract(const Duration(days: 30));
      case '3months':
        return DateTime.now().subtract(const Duration(days: 90));
      case '6months':
        return DateTime.now().subtract(const Duration(days: 180));
      case 'year':
        return DateTime.now().subtract(const Duration(days: 365));
      default:
        return DateTime.now().subtract(const Duration(days: 7));
    }
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'Weekly Report';
      case 'month':
        return 'Monthly Report';
      case '3months':
        return '3-Month Report';
      case '6months':
        return '6-Month Report';
      case 'year':
        return 'Yearly Report';
      default:
        return 'Progress Report';
    }
  }

  Map<String, dynamic> _calculateStatistics(
    BodyMeasurementProvider measurementProvider,
    WorkoutProvider workoutProvider,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Workout statistics
    final workoutHistory = workoutProvider.workoutHistory
        .where((w) => w.endTime != null && 
              w.endTime!.isAfter(startDate) && 
              w.endTime!.isBefore(endDate))
        .toList();

    final workoutCount = workoutHistory.length;
    final totalMinutes = workoutHistory.fold<int>(
      0, 
      (sum, w) => sum + (w.duration?.inMinutes ?? 0),
    );
    final totalExercises = workoutHistory.fold<int>(
      0,
      (sum, w) => sum + w.exerciseLogs.length,
    );

    // Personal records in period
    final prsInPeriod = measurementProvider.personalRecords
        .where((pr) => pr.achievedDate.isAfter(startDate) && 
              pr.achievedDate.isBefore(endDate))
        .toList();

    // Body measurements
    final measurementsInPeriod = measurementProvider.measurements
        .where((m) => m.date.isAfter(startDate) && m.date.isBefore(endDate))
        .toList();

    final startMeasurement = measurementsInPeriod.isNotEmpty 
        ? measurementsInPeriod.last 
        : null;
    final endMeasurement = measurementsInPeriod.isNotEmpty 
        ? measurementsInPeriod.first 
        : null;

    double? weightChange;
    if (startMeasurement?.weight != null && endMeasurement?.weight != null) {
      weightChange = endMeasurement!.weight! - startMeasurement!.weight!;
    }

    double? bodyFatChange;
    if (startMeasurement?.bodyFat != null && endMeasurement?.bodyFat != null) {
      bodyFatChange = endMeasurement!.bodyFat! - startMeasurement!.bodyFat!;
    }

    // Goals
    final goals = measurementProvider.goals;
    final activeGoals = goals.where((g) => !g.isCompleted).length;
    final completedGoalsInPeriod = goals
        .where((g) => g.isCompleted && 
              g.targetDate.isAfter(startDate) && 
              g.targetDate.isBefore(endDate))
        .length;

    double? goalProgress;
    if (activeGoals > 0) {
      final totalProgress = goals
          .where((g) => !g.isCompleted)
          .fold<double>(0, (sum, g) {
            return sum + (g.progress / 100);
          });
      goalProgress = totalProgress / activeGoals;
    }

    // Progress photos
    final photosInPeriod = measurementProvider.photos
        .where((p) => p.date.isAfter(startDate) && p.date.isBefore(endDate))
        .length;

    // Most active day
    String mostActiveDay = 'N/A';
    if (workoutHistory.isNotEmpty) {
      final dayCount = <String, int>{};
      for (var workout in workoutHistory) {
        if (workout.endTime != null) {
          final day = DateFormat('EEEE').format(workout.endTime!);
          dayCount[day] = (dayCount[day] ?? 0) + 1;
        }
      }
      if (dayCount.isNotEmpty) {
        mostActiveDay = dayCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
    }

    // Latest PR
    String? latestPR;
    if (prsInPeriod.isNotEmpty) {
      final pr = prsInPeriod.first;
      latestPR = '${pr.exerciseName}: ${pr.weight.toStringAsFixed(1)}kg × ${pr.reps} reps';
    }

    return {
      'workoutCount': workoutCount,
      'totalDuration': _formatDuration(totalMinutes),
      'avgDuration': workoutCount > 0 
          ? _formatDuration(totalMinutes ~/ workoutCount)
          : '0 min',
      'totalExercises': totalExercises,
      'mostActiveDay': mostActiveDay,
      'newPRs': prsInPeriod.length,
      'latestPR': latestPR,
      'startWeight': startMeasurement?.weight != null
          ? '${startMeasurement!.weight!.toStringAsFixed(1)} kg'
          : 'N/A',
      'endWeight': endMeasurement?.weight != null
          ? '${endMeasurement!.weight!.toStringAsFixed(1)} kg'
          : 'N/A',
      'weightChange': weightChange,
      'startBodyFat': startMeasurement?.bodyFat != null
          ? '${startMeasurement!.bodyFat!.toStringAsFixed(1)}%'
          : null,
      'endBodyFat': endMeasurement?.bodyFat != null
          ? '${endMeasurement!.bodyFat!.toStringAsFixed(1)}%'
          : null,
      'bodyFatChange': bodyFatChange,
      'activeGoals': activeGoals,
      'completedGoals': completedGoalsInPeriod,
      'goalProgress': goalProgress,
      'photosAdded': photosInPeriod,
    };
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}min';
  }

  Future<void> _shareReport(BuildContext context) async {
    try {
      final pdf = await _generatePDF(context);
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/musclemax_report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'MuscleMax Progress Report',
        text: 'Check out my fitness progress report!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printReport(BuildContext context) async {
    try {
      final pdf = await _generatePDF(context);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'MuscleMax_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final measurementProvider = context.read<BodyMeasurementProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    
    final startDate = _getStartDate();
    final endDate = DateTime.now();
    final stats = _calculateStatistics(
      measurementProvider,
      workoutProvider,
      startDate,
      endDate,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MUSCLEMAX PROGRESS REPORT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Workout Summary
              _buildPDFSection('WORKOUT SUMMARY', [
                _buildPDFStat('Workouts Completed', '${stats['workoutCount']}'),
                _buildPDFStat('Total Duration', stats['totalDuration']),
                _buildPDFStat('Total Exercises', '${stats['totalExercises']}'),
                _buildPDFStat('Average Workout Time', stats['avgDuration']),
                _buildPDFStat('Most Active Day', stats['mostActiveDay']),
              ]),
              pw.SizedBox(height: 16),

              // Personal Records
              _buildPDFSection('PERSONAL RECORDS', [
                _buildPDFStat('New PRs Achieved', '${stats['newPRs']}'),
                if (stats['latestPR'] != null)
                  _buildPDFStat('Latest PR', stats['latestPR']),
              ]),
              pw.SizedBox(height: 16),

              // Body Measurements
              _buildPDFSection('BODY MEASUREMENTS', [
                _buildPDFStat('Starting Weight', stats['startWeight']),
                _buildPDFStat('Current Weight', stats['endWeight']),
                if (stats['weightChange'] != null)
                  _buildPDFStat(
                    'Weight Change',
                    '${stats['weightChange'] > 0 ? '+' : ''}${stats['weightChange'].toStringAsFixed(1)} kg',
                  ),
                if (stats['startBodyFat'] != null)
                  _buildPDFStat('Starting Body Fat', stats['startBodyFat']),
                if (stats['endBodyFat'] != null)
                  _buildPDFStat('Current Body Fat', stats['endBodyFat']),
              ]),
              pw.SizedBox(height: 16),

              // Goals
              _buildPDFSection('GOALS PROGRESS', [
                _buildPDFStat('Active Goals', '${stats['activeGoals']}'),
                _buildPDFStat('Completed Goals', '${stats['completedGoals']}'),
              ]),
              pw.SizedBox(height: 16),

              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Generated by MuscleMax on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    color: PdfColors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPDFSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildPDFStat(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 12,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
