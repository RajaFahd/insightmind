import 'package:flutter/material.dart';
import '../theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  Widget _buildItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final bool selected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.peach.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: selected ? AppColors.peach : Colors.white70),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.peach : Colors.white70,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.subtleShadow, blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildItem(context, icon: Icons.home_filled, label: 'Home', index: 0),
          _buildItem(context, icon: Icons.shield, label: 'Screening', index: 1),
          _buildItem(context, icon: Icons.emoji_emotions, label: 'Emotion', index: 2),
          _buildItem(context, icon: Icons.receipt_long, label: 'Riwayat', index: 3),
          _buildItem(context, icon: Icons.person, label: 'Profile', index: 4),
        ],
      ),
    );
  }
}