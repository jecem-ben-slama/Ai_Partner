import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';

class FeedbackWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const FeedbackWrapper({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (onTap != null) {
          context.read<SoundService>().playTap();
          context.read<HapticService>().trigger();
          onTap!();
        }
      },
      child: IgnorePointer(
        ignoring: onTap != null,
        child: child,
      ),
    );
  }
}
