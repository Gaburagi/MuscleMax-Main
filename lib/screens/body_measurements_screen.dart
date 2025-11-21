import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';
import '../providers/body_measurement_provider.dart';
import '../models/body_measurement.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.progressHub),
        ),
        title: const Text('Body Measurements'),
        backgroundColor: AppColors.backgroundCard,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Goals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _HistoryTab(),
          _GoalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeasurementDialog(context),
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMeasurementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddMeasurementDialog(),
    );
  }
}

class _OverviewTab extends StatefulWidget {
  const _OverviewTab();

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  String _selectedPeriod = '30'; // Days

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BodyMeasurementProvider>();
    final latest = provider.latestMeasurement;

    if (latest == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_weight_outlined, size: 64, color: AppColors.textGray),
            SizedBox(height: 16),
            Text(
              'No measurements yet',
              style: TextStyle(color: AppColors.textGray, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first measurement',
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final weekChange = provider.getWeightChange(const Duration(days: 7));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: 'Current Weight',
            value: latest.weight != null ? '${latest.weight!.toStringAsFixed(1)} kg' : '--',
            subtitle: weekChange != null 
                ? '${weekChange >= 0 ? "+" : ""}${weekChange.toStringAsFixed(1)} kg this week'
                : 'No weekly data',
            icon: Icons.monitor_weight,
            color: AppColors.primaryRed,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Body Fat',
            value: latest.bodyFat != null ? '${latest.bodyFat!.toStringAsFixed(1)}%' : '--',
            subtitle: 'Last updated ${_formatDate(latest.date)}',
            icon: Icons.fitness_center,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),

          // Weight Trend Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 12),
          _buildWeightChart(provider),
          const SizedBox(height: 24),

          // Body Fat Chart
          if (provider.measurements.any((m) => m.bodyFat != null)) ...[
            const Text(
              'Body Fat Trend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBodyFatChart(provider),
            const SizedBox(height: 24),
          ],

          // Body Measurements
          const Text(
            'Body Measurements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMeasurementRow('Chest', latest.chest),
          _buildMeasurementRow('Waist', latest.waist),
          _buildMeasurementRow('Hips', latest.hips),
          _buildMeasurementRow('Biceps (L)', latest.bicepsLeft),
          _buildMeasurementRow('Biceps (R)', latest.bicepsRight),
          _buildMeasurementRow('Thigh (L)', latest.thighLeft),
          _buildMeasurementRow('Thigh (R)', latest.thighRight),
          _buildMeasurementRow('Calf (L)', latest.calfLeft),
          _buildMeasurementRow('Calf (R)', latest.calfRight),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        dropdownColor: AppColors.backgroundCard,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        items: const [
          DropdownMenuItem(value: '7', child: Text('7 Days')),
          DropdownMenuItem(value: '30', child: Text('30 Days')),
          DropdownMenuItem(value: '90', child: Text('90 Days')),
          DropdownMenuItem(value: '365', child: Text('1 Year')),
        ],
        onChanged: (value) {
          setState(() => _selectedPeriod = value!);
        },
      ),
    );
  }

  Widget _buildWeightChart(BodyMeasurementProvider provider) {
    final days = int.parse(_selectedPeriod);
    final startDate = DateTime.now().subtract(Duration(days: days));
    final measurements = provider.getMeasurementsForPeriod(startDate, DateTime.now())
        .where((m) => m.weight != null)
        .toList()
        .reversed
        .toList();

    if (measurements.length < 2) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Need at least 2 measurements to show chart',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < measurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), measurements[i].weight!));
    }

    final minY = measurements.map((m) => m.weight!).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = measurements.map((m) => m.weight!).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= measurements.length) return const Text('');
                  final date = measurements[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
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
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryRed,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryRed,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.3),
                    AppColors.primaryRed.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyFatChart(BodyMeasurementProvider provider) {
    final days = int.parse(_selectedPeriod);
    final startDate = DateTime.now().subtract(Duration(days: days));
    final measurements = provider.getMeasurementsForPeriod(startDate, DateTime.now())
        .where((m) => m.bodyFat != null)
        .toList()
        .reversed
        .toList();

    if (measurements.length < 2) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Need at least 2 body fat measurements to show chart',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < measurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), measurements[i].bodyFat!));
    }

    final minY = measurements.map((m) => m.bodyFat!).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = measurements.map((m) => m.bodyFat!).reduce((a, b) => a > b ? a : b) + 1;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= measurements.length) return const Text('');
                  final date = measurements[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toStringAsFixed(1)}%',
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
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.orange,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.orange.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textGray.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String label, double? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 16,
            ),
          ),
          Text(
            value != null ? '${value.toStringAsFixed(1)} cm' : '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BodyMeasurementProvider>();
    final measurements = provider.measurements;

    if (measurements.isEmpty) {
      return const Center(
        child: Text(
          'No measurement history',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        final measurement = measurements[index];
        return _buildHistoryCard(context, measurement, index);
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, BodyMeasurement measurement, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                DateFormat('MMM d, yyyy').format(measurement.date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed),
                onPressed: () => _confirmDelete(context, measurement.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (measurement.weight != null)
            _buildInfoRow('Weight', '${measurement.weight!.toStringAsFixed(1)} kg'),
          if (measurement.bodyFat != null)
            _buildInfoRow('Body Fat', '${measurement.bodyFat!.toStringAsFixed(1)}%'),
          if (measurement.chest != null)
            _buildInfoRow('Chest', '${measurement.chest!.toStringAsFixed(1)} cm'),
          if (measurement.waist != null)
            _buildInfoRow('Waist', '${measurement.waist!.toStringAsFixed(1)} cm'),
          if (measurement.notes != null && measurement.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                measurement.notes!,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Delete Measurement', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this measurement?',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () {
              context.read<BodyMeasurementProvider>().deleteMeasurement(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BodyMeasurementProvider>();
    final goals = provider.goals;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddGoalDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add New Goal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        if (goals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No goals set yet',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
          )
        else
          ...goals.map((goal) => _buildGoalCard(context, goal)),
      ],
    );
  }

  Widget _buildGoalCard(BuildContext context, FitnessGoal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: goal.isCompleted
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (goal.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal.progress / 100,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              goal.isCompleted ? Colors.green : AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${_getUnit(goal.type)}',
                style: const TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
              Text(
                '${goal.progress.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          if (!goal.isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${goal.daysRemaining} days remaining',
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.primaryRed),
                onPressed: () => _confirmDeleteGoal(context, goal.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUnit(String type) {
    switch (type) {
      case 'weight':
        return 'kg';
      case 'body_fat':
        return '%';
      case 'muscle_mass':
        return 'kg';
      default:
        return '';
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddGoalDialog(),
    );
  }

  void _confirmDeleteGoal(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Delete Goal', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this goal?',
          style: TextStyle(color: AppColors.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () {
              context.read<BodyMeasurementProvider>().deleteGoal(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}

class _AddMeasurementDialog extends StatefulWidget {
  const _AddMeasurementDialog();

  @override
  State<_AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<_AddMeasurementDialog> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _bicepsLController = TextEditingController();
  final _bicepsRController = TextEditingController();
  final _thighLController = TextEditingController();
  final _thighRController = TextEditingController();
  final _calfLController = TextEditingController();
  final _calfRController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _bicepsLController.dispose();
    _bicepsRController.dispose();
    _thighLController.dispose();
    _thighRController.dispose();
    _calfLController.dispose();
    _calfRController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: const Text('Add Measurement', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Date', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(color: AppColors.textGray),
                ),
                trailing: const Icon(Icons.calendar_today, color: AppColors.primaryRed),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              _buildTextField('Weight (kg)', _weightController),
              _buildTextField('Body Fat (%)', _bodyFatController),
              const SizedBox(height: 16),
              const Text(
                'Body Measurements (cm)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildTextField('Chest', _chestController),
              _buildTextField('Waist', _waistController),
              _buildTextField('Hips', _hipsController),
              _buildTextField('Biceps (Left)', _bicepsLController),
              _buildTextField('Biceps (Right)', _bicepsRController),
              _buildTextField('Thigh (Left)', _thighLController),
              _buildTextField('Thigh (Right)', _thighRController),
              _buildTextField('Calf (Left)', _calfLController),
              _buildTextField('Calf (Right)', _calfRController),
              const SizedBox(height: 8),
              _buildTextField('Notes', _notesController, maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGray)),
        ),
        ElevatedButton(
          onPressed: _saveMeasurement,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.number,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGray),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryRed),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              surface: AppColors.backgroundCard,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveMeasurement() {
    final measurement = BodyMeasurement(
      id: 'meas_${DateTime.now().millisecondsSinceEpoch}',
      date: _selectedDate,
      weight: _parseDouble(_weightController.text),
      bodyFat: _parseDouble(_bodyFatController.text),
      chest: _parseDouble(_chestController.text),
      waist: _parseDouble(_waistController.text),
      hips: _parseDouble(_hipsController.text),
      bicepsLeft: _parseDouble(_bicepsLController.text),
      bicepsRight: _parseDouble(_bicepsRController.text),
      thighLeft: _parseDouble(_thighLController.text),
      thighRight: _parseDouble(_thighRController.text),
      calfLeft: _parseDouble(_calfLController.text),
      calfRight: _parseDouble(_calfRController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    context.read<BodyMeasurementProvider>().addMeasurement(measurement);
    Navigator.pop(context);
  }

  double? _parseDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  
  String _selectedType = 'weight';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: const Text('Add Fitness Goal', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                labelStyle: TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryRed),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              dropdownColor: AppColors.backgroundCard,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Goal Type',
                labelStyle: TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryRed),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'weight', child: Text('Weight')),
                DropdownMenuItem(value: 'body_fat', child: Text('Body Fat %')),
                DropdownMenuItem(value: 'muscle_mass', child: Text('Muscle Mass')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _currentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Current Value',
                labelStyle: TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryRed),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Target Value',
                labelStyle: TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryRed),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Target Date', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                DateFormat('MMM d, yyyy').format(_targetDate),
                style: const TextStyle(color: AppColors.textGray),
              ),
              trailing: const Icon(Icons.calendar_today, color: AppColors.primaryRed),
              onTap: _selectTargetDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGray)),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              surface: AppColors.backgroundCard,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _saveGoal() {
    if (_titleController.text.isEmpty || _targetController.text.isEmpty || _currentController.text.isEmpty) {
      return;
    }

    final goal = FitnessGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      type: _selectedType,
      targetValue: double.parse(_targetController.text),
      currentValue: double.parse(_currentController.text),
      startDate: DateTime.now(),
      targetDate: _targetDate,
    );

    context.read<BodyMeasurementProvider>().addGoal(goal);
    Navigator.pop(context);
  }
}

