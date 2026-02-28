import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/translation/translation_cubit.dart';
import 'package:ai_partner/logic/cubit/translation/translation_state.dart';
import 'package:ai_partner/presentation/screens/tts_player_page.dart';
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
  TranslateLanguage? _targetLang;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? "");

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TranslationCubit>().detectAndSetScannedText(
          widget.initialText!,
        );
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  TranslateLanguage? _mapCodeToLanguage(String code) {
    return BCP47Code.fromRawValue(code);
  }

  void _swapLanguages() {
    if (_targetLang != null) {
      setState(() {
        final temp = _sourceLang;
        _sourceLang = _targetLang!;
        _targetLang = temp;
      });
    }
  }

  String _getLocalizedLanguageName(
    BuildContext context,
    TranslateLanguage lang,
  ) {
    switch (lang) {
      case TranslateLanguage.french:
        return "Français";
      case TranslateLanguage.arabic:
        return "العربية";
      case TranslateLanguage.english:
        return "English";
      case TranslateLanguage.spanish:
        return "Español";
      case TranslateLanguage.german:
        return "Deutsch";
      case TranslateLanguage.italian:
        return "Italiano";
      default:
        return lang.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationCubit, TranslationState>(
      listener: (context, state) {
        if (state is TranslationDetected) {
          final detected = _mapCodeToLanguage(state.detectedLangCode);
          if (detected != null) {
            setState(() => _sourceLang = detected);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.translationLabel),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildLanguageSelector(),
              _buildDetectionStatus(),
              const SizedBox(height: 15),
              _buildInputArea(),
              const SizedBox(height: 20),
              _buildActionButton(),
              const SizedBox(height: 25),
              _buildOutputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionStatus() {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        // Only show detection status if there is actually text to detect
        if (_textController.text.isEmpty) return const SizedBox.shrink();

        if (state is TranslationDetecting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Identifying language...",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey,
              ),
            ),
          );
        }

        if (state is TranslationDetected) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 5),
                Text(
                  "Detected: ${_getLocalizedLanguageName(context, _sourceLang)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
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
              "From",
            ),
          ),
          IconButton(
            onPressed: _targetLang == null ? null : _swapLanguages,
            icon: Icon(
              Icons.swap_horiz,
              color: _targetLang == null
                  ? Colors.grey
                  : (Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
            ),
          ),
          Expanded(
            child: _langDropdown(
              _targetLang,
              (v) => setState(() => _targetLang = v),
              "Translate to",
            ),
          ),
        ],
      ),
    );
  }

  Widget _langDropdown(
    TranslateLanguage? current,
    ValueChanged<TranslateLanguage?> onChanged,
    String hintText,
  ) {
    return DropdownButton<TranslateLanguage>(
      value: current,
      isExpanded: true,
      underline: const SizedBox(),
      hint: Text(
        hintText,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
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
          child: Text(_getLocalizedLanguageName(context, lang)),
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
        onChanged: (_) => setState(
          () {},
        ), // Trigger rebuild to update detection status and button
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.translationHint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        final bool isBusy =
            state is TranslationLoading || state is TranslationDetecting;
        final bool canTranslate =
            _targetLang != null && _textController.text.trim().isNotEmpty;

        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: (isBusy || !canTranslate)
                ? null
                : () {
                    context.read<TranslationCubit>().translateText(
                      text: _textController.text,
                      source: _sourceLang,
                      target: _targetLang!,
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
            child: isBusy
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _targetLang == null
                        ? "Pick a target language"
                        : AppLocalizations.of(context)!.translationLabel,
                    style: const TextStyle(color: Colors.white),
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

        if (displayResult.isEmpty && state is! TranslationLoading)
          return const SizedBox.shrink();

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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state is TranslationSuccess) ...[
                    IconButton(
                      icon: Icon(
                        Icons.volume_up_rounded,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TtsPlayerPage(text: state.translatedText),
                          ),
                        );
                      },
                    ),
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
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                displayResult,
                style: TextStyle(
                  color: state is TranslationError
                      ? Colors.redAccent
                      : (Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.greenAccent),
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
