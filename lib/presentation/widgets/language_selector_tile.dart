import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/models/language_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/settings/settings_cubit.dart';

class LanguageSelectorTile extends StatelessWidget {
  final String title;
  final String currentLanguageCode;

  const LanguageSelectorTile({
    super.key,
    required this.title,
    required this.currentLanguageCode,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.language_outlined),
      tileColor: Theme.of(context).colorScheme.surface,
      iconColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Theme.of(context).colorScheme.primary,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLanguageCode,
          items: LanguageModel.languages.map((lang) {
            return DropdownMenuItem(
              value: lang.code,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.flag),
                  const SizedBox(width: 8),
                  Text(lang.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (code) {
            if (code != null) {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              context.read<SettingsCubit>().changeLanguage(code);
            }
          },
        ),
      ),
    );
  }
}
