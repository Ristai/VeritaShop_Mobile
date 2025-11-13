import 'package:flutter/material.dart';

class ActionCardViewModel {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final Color statusColor;
  final String description;

  ActionCardViewModel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.description,
  });
}
