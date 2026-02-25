import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/translation/translation_cubit.dart';
import 'package:ai_partner/logic/cubit/translation/translation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslatorScreen extends StatefulWidget {
  final String? initialText;
  const TranslatorScreen({super.key, this.initialText});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  late TextEditingController _textController;
  TranslateLanguage _sourceLang = TranslateLanguage.english;
  TranslateLanguage _targetLang = TranslateLanguage.french;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? "");
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Language Selector Row
            _buildLanguageSelector(),
            const SizedBox(height: 25),

            // 2. Input Card
            _buildInputArea(),
            const SizedBox(height: 20),

            // 3. Action Buttons & Status
            _buildActionButton(),
            const SizedBox(height: 25),

            // 4. Output Card (Result)
            _buildOutputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white70
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.surfaceDark, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _langDropdown(
              _sourceLang,
              (v) => setState(() => _sourceLang = v!),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.swap_horiz,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            onPressed: _swapLanguages,
          ),
          Expanded(
            child: _langDropdown(
              _targetLang,
              (v) => setState(() => _targetLang = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _langDropdown(
    TranslateLanguage current,
    ValueChanged<TranslateLanguage?> onChanged,
  ) {
    return DropdownButton<TranslateLanguage>(
      value: current,
      isExpanded: true,
      underline: const SizedBox(),

      dropdownColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.surfaceDark,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        fontSize: 14,
      ),
      items: TranslateLanguage.values.map((lang) {
        return DropdownMenuItem(
          value: lang,
          child: Text(lang.name.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white70
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.surfaceDark, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: 6,
        style: TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.translationHint,
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        final isLoading = state is TranslationLoading;
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<TranslationCubit>().translateText(
                      text: _textController.text,
                      source: _sourceLang,
                      target: _targetLang,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? AppColors.primaryLight
                  : AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    AppLocalizations.of(context)!.translationLabel,
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOutputArea() {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        String displayResult = "";
        if (state is TranslationSuccess) displayResult = state.translatedText;
        if (state is TranslationError) displayResult = "Error: ${state.error}";
        if (state is TranslationLoading) displayResult = state.message;

        if (displayResult.isEmpty && state is! TranslationLoading) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white70
                : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.surfaceDark, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state is TranslationSuccess)
                    IconButton(
                      icon: Icon(
                        Icons.copy,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: state.translatedText),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Result copied")),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                displayResult,
                style: TextStyle(
                  color: state is TranslationError
                      ? Colors.redAccent
                      : Colors.greenAccent,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
