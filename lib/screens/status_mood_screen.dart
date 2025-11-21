import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/profile_stats_provider.dart';
import '../models/profile_extensions.dart';

class StatusMoodScreen extends StatefulWidget {
  const StatusMoodScreen({super.key});

  @override
  State<StatusMoodScreen> createState() => _StatusMoodScreenState();
}

class _StatusMoodScreenState extends State<StatusMoodScreen> {
  ProfileMood? _selectedMood;
  final _statusController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    final statsProvider = context.read<ProfileStatsProvider>();
    final status = await statsProvider.getCurrentStatus();
    setState(() {
      _selectedMood = status['mood'] as ProfileMood?;
      _statusController.text = status['customText'] as String? ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveStatus() async {
    final statsProvider = context.read<ProfileStatsProvider>();
    await statsProvider.updateStatus(
      mood: _selectedMood,
      customText: _statusController.text.trim().isEmpty
          ? null
          : _statusController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated!')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _clearStatus() async {
    final statsProvider = context.read<ProfileStatsProvider>();
    await statsProvider.clearStatus();

    if (mounted) {
      setState(() {
        _selectedMood = null;
        _statusController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status cleared')),
      );
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'SET STATUS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_selectedMood != null || _statusController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearStatus,
              tooltip: 'Clear Status',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom status text
                  const Text(
                    'Custom Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _statusController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryRed),
                      ),
                      counterStyle: const TextStyle(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Mood selection
                  const Text(
                    'Select Mood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose how you\'re feeling today',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mood grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: ProfileMood.values.length,
                    itemBuilder: (context, index) {
                      final mood = ProfileMood.values[index];
                      final isSelected = _selectedMood == mood;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = isSelected ? null : mood;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryRed.withOpacity(0.2)
                                : AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  mood.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primaryRed
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Preview
                  if (_selectedMood != null || _statusController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryRed),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (_selectedMood != null) ...[
                                Text(
                                  _selectedMood!.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  _statusController.text.isEmpty
                                      ? (_selectedMood?.label ?? '')
                                      : _statusController.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _saveStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SAVE STATUS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
