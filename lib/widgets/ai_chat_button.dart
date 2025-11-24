import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/ai_chat_screen.dart';

class AIChatButton extends StatelessWidget {
  const AIChatButton({super.key});

  void _showAIChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 90,
      child: GestureDetector(
        onTap: () => _showAIChat(context),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryRed, Color(0xFFFF6B9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
