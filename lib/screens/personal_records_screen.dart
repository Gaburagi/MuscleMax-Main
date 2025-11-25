import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/exercise_video_player.dart';
import '../widgets/local_video_player.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../providers/body_measurement_provider.dart';
import '../models/body_measurement.dart';
class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen> with SingleTickerProviderStateMixin {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.go('/home');
              },
          ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddPRDialog(context),
          backgroundColor: AppColors.primaryRed,
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Add PR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }
  late TabController _tabController;
  String _selectedFilter = 'all';

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

  void _showAddPRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddPersonalRecordDialog(),
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
                  // Media preview below PR details
                  if (record.mediaProofPath != null && record.mediaProofPath!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            Widget mediaWidget;
                            if (record.mediaProofType == 'photo') {
                              mediaWidget = Image.file(
                                File(record.mediaProofPath!),
                                fit: BoxFit.contain,
                              );
                            } else if (record.mediaProofType == 'video') {
                              mediaWidget = LocalVideoPlayer(videoPath: record.mediaProofPath!);
                            } else {
                              mediaWidget = const SizedBox.shrink();
                            }
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.black,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: mediaWidget,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: record.mediaProofType == 'photo'
                          ? Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color, width: 2),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.file(
                                File(record.mediaProofPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color, width: 2),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    color: Colors.black,
                                  ),
                                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                                ],
                              ),
                            ),
                    ),
                  ],
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

class _AddPersonalRecordDialog extends StatefulWidget {
  const _AddPersonalRecordDialog();

  @override
  State<_AddPersonalRecordDialog> createState() => _AddPersonalRecordDialogState();
}

class _AddPersonalRecordDialogState extends State<_AddPersonalRecordDialog> {
  final _exerciseNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _recordType = 'max_weight';
  File? _mediaFile;
  String? _mediaType; // 'photo' or 'video'
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.emoji_events, color: AppColors.primaryRed, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add Personal Record',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exercise Details',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Exercise Name',
                _exerciseNameController,
                Icons.fitness_center,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _recordType,
                dropdownColor: AppColors.backgroundCard,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Record Type',
                  labelStyle: const TextStyle(color: AppColors.textGray),
                  prefixIcon: const Icon(Icons.category, color: AppColors.primaryRed),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                ),
                items: const [
                  DropdownMenuItem(value: 'max_weight', child: Text('Max Weight')),
                  DropdownMenuItem(value: 'max_volume', child: Text('Max Volume')),
                ],
                onChanged: (value) => setState(() => _recordType = value!),
              ),
              const SizedBox(height: 16),
              const Text(
                'Performance',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Weight (kg)',
                      _weightController,
                      Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Reps',
                      _repsController,
                      Icons.repeat,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Proof (Optional)',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_camera, size: 20),
                      label: const Text('Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _mediaType == 'photo' ? AppColors.primaryRed : Colors.white,
                        side: BorderSide(
                          color: _mediaType == 'photo' ? AppColors.primaryRed : AppColors.textGray.withOpacity(0.3),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam, size: 20),
                      label: const Text('Video'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _mediaType == 'video' ? AppColors.primaryRed : Colors.white,
                        side: BorderSide(
                          color: _mediaType == 'video' ? AppColors.primaryRed : AppColors.textGray.withOpacity(0.3),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_mediaFile != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _mediaType == 'photo' ? Icons.image : Icons.videocam,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _mediaFile!.path.split('/').last,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primaryRed, size: 20),
                        onPressed: () => setState(() {
                          _mediaFile = null;
                          _mediaType = null;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textGray.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primaryRed, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date Achieved',
                            style: TextStyle(color: AppColors.textGray, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: AppColors.textGray, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGray, fontSize: 16)),
        ),
        ElevatedButton.icon(
          onPressed: _savePR,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Save PR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGray),
        prefixIcon: Icon(icon, color: AppColors.primaryRed),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: AppColors.backgroundDark,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() {
          _mediaFile = File(photo.path);
          _mediaType = 'photo';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _mediaFile = File(video.path);
          _mediaType = 'video';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking video: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

  void _savePR() {
    if (_exerciseNameController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid weight and reps'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pr = PersonalRecord(
      id: 'pr_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: _exerciseNameController.text.toLowerCase().replaceAll(' ', '_'),
      exerciseName: _exerciseNameController.text,
      weight: weight,
      reps: reps,
      recordType: _recordType,
      achievedDate: _selectedDate,
      mediaProofPath: _mediaFile?.path,
      mediaProofType: _mediaType,
    );

    context.read<BodyMeasurementProvider>().addPersonalRecord(pr);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 12),
            const Text('Personal Record added successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

