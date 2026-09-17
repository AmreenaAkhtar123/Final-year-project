import 'package:flutter/material.dart';



import '../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 20,
          ),
        ),

        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
        children: [
          _buildNotification(
            icon: Icons.favorite_rounded,
            title: 'Daily check-in reminder',
            message: 'Take a moment to check in with yourself today.',
            time: 'Today',
            iconBackground: AppColors.lightMint,
            iconColor: AppColors.mint,
          ),

          const SizedBox(height: 12),

          _buildNotification(
            icon: Icons.auto_awesome_rounded,
            title: 'MindMate insight',
            message: 'Your recent mood pattern has been looking positive.',
            time: 'Yesterday',
            iconBackground: const Color(0xFFF1F3FC),
            iconColor: const Color(0xFF6B7FD7),
          ),

          const SizedBox(height: 12),

          _buildNotification(
            icon: Icons.psychology_outlined,
            title: 'Wellbeing check',
            message: 'You can complete your weekly wellbeing assessment.',
            time: '2 days ago',
            iconBackground: const Color(0xFFFFF5E9),
            iconColor: const Color(0xFFE29A45),
          ),
        ],
      ),
    );
  }

  Widget _buildNotification({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.40),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.55),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}