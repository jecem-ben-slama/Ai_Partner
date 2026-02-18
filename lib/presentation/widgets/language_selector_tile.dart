import 'package:ai_partner/data/models/language_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings/settings_cubit.dart';
import '../../core/theme/app_colors.dart';

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
      tileColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.surfaceLight
          : AppColors.surfaceDark,
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.black
              : AppColors.white,
        ),
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
              context.read<SettingsCubit>().changeLanguage(code);
            }
          },
        ),
      ),
    );
  }
}
