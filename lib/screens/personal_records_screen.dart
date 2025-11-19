import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../providers/body_measurement_provider.dart';
import '../models/body_measurement.dart';

class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all'; // all, recent, this_month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Personal Records'),
        backgroundColor: AppColors.backgroundDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'All Records'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllRecordsTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildAllRecordsTab() {
    final provider = context.watch<BodyMeasurementProvider>();
    final records = provider.personalRecords;

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: AppColors.textGray.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No personal records yet',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete workouts to set your first PR!',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Group records by exercise
    final groupedRecords = <String, List<PersonalRecord>>{};
    for (var record in records) {
      if (!groupedRecords.containsKey(record.exerciseId)) {
        groupedRecords[record.exerciseId] = [];
      }
      groupedRecords[record.exerciseId]!.add(record);
    }

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Time', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Recent', 'recent'),
                const SizedBox(width: 8),
                _buildFilterChip('This Month', 'this_month'),
              ],
            ),
          ),
        ),

        // Records list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groupedRecords.length,
            itemBuilder: (context, index) {
              final exerciseId = groupedRecords.keys.elementAt(index);
              final exerciseRecords = groupedRecords[exerciseId]!;
              final exerciseName = exerciseRecords.first.exerciseName;

              return _buildExerciseRecordCard(exerciseName, exerciseRecords);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : AppColors.textGray.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGray,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseRecordCard(String exerciseName, List<PersonalRecord> records) {
    final maxWeightRecord = records.where((r) => r.recordType == 'max_weight').firstOrNull;
    final maxVolumeRecord = records.where((r) => r.recordType == 'max_volume').firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Max Weight
          if (maxWeightRecord != null) ...[
            _buildRecordRow(
              'Max Weight',
              '${maxWeightRecord.weight.toStringAsFixed(1)} kg × ${maxWeightRecord.reps} reps',
              _formatDate(maxWeightRecord.achievedDate),
              Icons.fitness_center,
              Colors.orange,
            ),
            const SizedBox(height: 12),
          ],

          // Max Volume
          if (maxVolumeRecord != null) ...[
            _buildRecordRow(
              'Max Volume',
              '${maxVolumeRecord.volume.toStringAsFixed(0)} kg',
              _formatDate(maxVolumeRecord.achievedDate),
              Icons.show_chart,
              Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordRow(String label, String value, String date, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
    final provider = context.watch<BodyMeasurementProvider>();
    final records = provider.personalRecords.toList()
      ..sort((a, b) => b.achievedDate.compareTo(a.achievedDate));

    if (records.isEmpty) {
      return const Center(
        child: Text(
          'No records to display',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final isFirst = index == 0;
        final isLast = index == records.length - 1;

        return _buildTimelineItem(record, isFirst, isLast);
      },
    );
  }

  Widget _buildTimelineItem(PersonalRecord record, bool isFirst, bool isLast) {
    final color = record.recordType == 'max_weight' ? Colors.orange : Colors.blue;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.textGray.withOpacity(0.3),
                    ),
                  ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.textGray.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          record.recordType == 'max_weight' ? 'MAX WEIGHT' : 'MAX VOLUME',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(record.achievedDate),
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    record.exerciseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.fitness_center, size: 16, color: color),
                      const SizedBox(width: 8),
                      Text(
                        '${record.weight.toStringAsFixed(1)} kg × ${record.reps} reps',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                      if (record.recordType == 'max_volume') ...[
                        const SizedBox(width: 12),
                        Icon(Icons.calculate, size: 16, color: color),
                        const SizedBox(width: 8),
                        Text(
                          '${record.volume.toStringAsFixed(0)} kg total',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
