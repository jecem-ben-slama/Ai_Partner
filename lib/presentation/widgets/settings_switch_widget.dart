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
      iconColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Theme.of(context).colorScheme.primary,
      tileColor: Theme.of(context).colorScheme.surface,
      title: Text(
        widget.title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}
