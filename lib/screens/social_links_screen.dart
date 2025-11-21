import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/profile_stats_provider.dart';
import '../models/profile_extensions.dart';

class SocialLinksScreen extends StatefulWidget {
  const SocialLinksScreen({super.key});

  @override
  State<SocialLinksScreen> createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends State<SocialLinksScreen> {
  List<SocialLink> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final statsProvider = context.read<ProfileStatsProvider>();
    final links = await statsProvider.getSocialLinks();
    setState(() {
      _links = links;
      _isLoading = false;
    });
  }

  Future<void> _addLink(SocialLink link) async {
    final statsProvider = context.read<ProfileStatsProvider>();
    await statsProvider.addSocialLink(link);
    await _loadLinks();
  }

  Future<void> _removeLink(int index) async {
    final statsProvider = context.read<ProfileStatsProvider>();
    await statsProvider.removeSocialLink(index);
    await _loadLinks();
  }

  void _showAddLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddLinkDialog(
        onAdd: _addLink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'SOCIAL LINKS',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_links.length < 5)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddLinkDialog,
              tooltip: 'Add Link',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : _links.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    final link = _links[index];
                    return _LinkCard(
                      link: link,
                      onDelete: () => _removeLink(index),
                    );
                  },
                ),
      floatingActionButton: _links.length < 5
          ? FloatingActionButton(
              onPressed: _showAddLinkDialog,
              backgroundColor: AppColors.primaryRed,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No social links yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect your social media accounts',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddLinkDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Link'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final SocialLink link;
  final VoidCallback onDelete;

  const _LinkCard({
    required this.link,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D31), // Discord dark background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Platform icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getPlatformColor(link.platform).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPlatformIcon(link.platform),
              color: _getPlatformColor(link.platform),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Platform and URL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.displayName ?? _getPlatformName(link.platform),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  link.url,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'instagram':
        return Icons.photo_camera; // Instagram camera
      case 'tiktok':
        return Icons.music_video; // TikTok music
      case 'youtube':
        return Icons.play_circle_filled; // YouTube play
      case 'spotify':
        return Icons.audiotrack; // Spotify music
      case 'twitter':
        return Icons.tag; // Twitter/X
      case 'discord':
        return Icons.forum; // Discord chat
      case 'twitch':
        return Icons.videocam; // Twitch stream
      case 'website':
        return Icons.public; // Website globe
      default:
        return Icons.link;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'instagram':
        return const Color(0xFFE1306C); // Instagram pink
      case 'tiktok':
        return const Color(0xFF00F2EA); // TikTok cyan
      case 'youtube':
        return const Color(0xFFFF0000); // YouTube red
      case 'spotify':
        return const Color(0xFF1DB954); // Spotify green
      case 'twitter':
        return const Color(0xFF1DA1F2); // Twitter blue
      case 'discord':
        return const Color(0xFF5865F2); // Discord blurple
      case 'twitch':
        return const Color(0xFF9146FF); // Twitch purple
      case 'website':
        return const Color(0xFF5865F2); // Discord blue
      default:
        return const Color(0xFF99AAB5); // Discord gray
    }
  }

  String _getPlatformName(String platform) {
    return platform[0].toUpperCase() + platform.substring(1);
  }
}

class _AddLinkDialog extends StatefulWidget {
  final Function(SocialLink) onAdd;

  const _AddLinkDialog({required this.onAdd});

  @override
  State<_AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<_AddLinkDialog> {
  String _selectedPlatform = 'instagram';
  final _urlController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a URL')),
      );
      return;
    }

    final link = SocialLink(
      platform: _selectedPlatform,
      url: _urlController.text.trim(),
      displayName: _displayNameController.text.trim().isEmpty
          ? null
          : _displayNameController.text.trim(),
      icon: _selectedPlatform,
    );

    widget.onAdd(link);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: const Text(
        'Add Social Link',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Platform',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButton<String>(
                value: _selectedPlatform,
                isExpanded: true,
                dropdownColor: AppColors.backgroundCard,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                  DropdownMenuItem(value: 'tiktok', child: Text('TikTok')),
                  DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
                  DropdownMenuItem(value: 'spotify', child: Text('Spotify')),
                  DropdownMenuItem(value: 'discord', child: Text('Discord')),
                  DropdownMenuItem(value: 'twitter', child: Text('Twitter/X')),
                  DropdownMenuItem(value: 'twitch', child: Text('Twitch')),
                  DropdownMenuItem(value: 'website', child: Text('Website')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom Link')),
                ],
                onChanged: (value) {
                  setState(() => _selectedPlatform = value!);
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'URL',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Display Name (Optional)',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Custom label',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
