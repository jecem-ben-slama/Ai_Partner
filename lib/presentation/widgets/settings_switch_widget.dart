import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsSwitchWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const SettingsSwitchWidget({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  State<SettingsSwitchWidget> createState() => _SettingsSwitchWidgetState();
}

class _SettingsSwitchWidgetState extends State<SettingsSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(widget.icon),
      tileColor: AppColors.surfaceLight,
      title: Text(widget.title, style: TextStyle(color: AppColors.black)),
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}
