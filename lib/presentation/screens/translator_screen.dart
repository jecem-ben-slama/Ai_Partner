import 'package:ai_partner/core/theme/app_colors.dart';
import 'package:ai_partner/core/l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context)!;
        context.read<TranslationCubit>().detectAndSetScannedText(
          widget.initialText!,
          errorMessage: l10n.identifyError,
        );
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    if (_targetLang != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        final temp = _sourceLang;
        _sourceLang = _targetLang!;
        _targetLang = temp;
      });
    }
  }

  void _showLanguagePicker(bool isSource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: TranslateLanguage.values.length,
                  itemBuilder: (context, index) {
                    final lang = TranslateLanguage.values[index];
                    return ListTile(
                      title: Text(_getLocalizedLanguageName(context, lang)),
                      trailing: (isSource ? _sourceLang : _targetLang) == lang
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      onTap: () {
                        setState(
                          () => isSource
                              ? _sourceLang = lang
                              : _targetLang = lang,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLocalizedLanguageName(
    BuildContext context,
    TranslateLanguage lang,
  ) {
    final map = {
      TranslateLanguage.french: "Français",
      TranslateLanguage.arabic: "العربية",
      TranslateLanguage.english: "English",
      TranslateLanguage.spanish: "Español",
      TranslateLanguage.german: "Deutsch",
      TranslateLanguage.italian: "Italiano",
    };
    return map[lang] ?? lang.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<TranslationCubit, TranslationState>(
      listener: (context, state) {
        if (state is TranslationDetected) {
          final detected = BCP47Code.fromRawValue(state.detectedLangCode);
          if (detected != null) setState(() => _sourceLang = detected);
        }
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildLanguageRow(l10n),
              _buildDetectionStatus(l10n),
              const SizedBox(height: 20),
              _buildInputCard(l10n),
              const SizedBox(height: 24),
              _buildTranslateButton(l10n),
              const SizedBox(height: 24),
              _buildOutputArea(l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageRow(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLangButton(_sourceLang, true),
          IconButton(
            onPressed: _targetLang == null ? null : _swapLanguages,
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.blueAccent,
            ),
          ),
          _buildLangButton(_targetLang, false, hint: l10n.translatetoLabel),
        ],
      ),
    );
  }

  Widget _buildLangButton(
    TranslateLanguage? lang,
    bool isSource, {
    String? hint,
  }) {
    return InkWell(
      onTap: () => _showLanguagePicker(isSource),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          lang != null
              ? _getLocalizedLanguageName(context, lang)
              : (hint ?? "Select"),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: lang != null
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 5,
            onChanged: (v) => setState(() {}),
            style: const TextStyle(fontSize: 17, height: 1.4),
            decoration: InputDecoration(
              hintText: l10n.textHint,
              border: InputBorder.none,
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => setState(() => _textController.clear()),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton(AppLocalizations l10n) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        final isBusy =
            state is TranslationLoading || state is TranslationDetecting;
        final canTranslate =
            _targetLang != null && _textController.text.trim().isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (isBusy || !canTranslate)
                ? null
                : () {
                    context.read<TranslationCubit>().translateText(
                      text: _textController.text,
                      source: _sourceLang,
                      target: _targetLang!,
                      translatingMessage: l10n.translatingLabel,
                      downloadingMessage: l10n.downloadingLabel,
                      errorMessage: l10n.translationError,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              elevation: canTranslate ? 4 : 0,
            ),
            child: isBusy
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _targetLang == null
                        ? l10n.picktarget
                        : l10n.translationLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOutputArea(AppLocalizations l10n) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        // Updated Logic: Only show the box if we are explicitly Loading, Success, or Error.
        // It will NOT show for TranslationInitial or TranslationDetected.
        if (_textController.text.trim().isEmpty ||
            (state is! TranslationLoading &&
                state is! TranslationSuccess &&
                state is! TranslationError)) {
          return const SizedBox.shrink();
        }

        String content = "";
        bool isError = false;
        if (state is TranslationSuccess) content = state.translatedText;
        if (state is TranslationError) {
          content = state.error;
          isError = true;
        }
        if (state is TranslationLoading) content = state.message;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isError ? Colors.red : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isError
                      ? Colors.redAccent
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    content,
                    style: TextStyle(
                      fontSize: 18,
                      color: isError ? Colors.redAccent : null,
                      height: 1.4,
                    ),
                  ),
                  if (state is TranslationSuccess) ...[
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCircleAction(
                          Icons.volume_up_rounded,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => TtsPlayerPage(text: content),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildCircleAction(Icons.copy_rounded, () {
                          Clipboard.setData(ClipboardData(text: content));
                          _showTopNotification(context, l10n.copiedLabel);
                        }),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTopNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF161925),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildDetectionStatus(AppLocalizations l10n) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        if (state is TranslationDetecting) {
          return const LinearProgressIndicator(minHeight: 2);
        }
        if (state is TranslationDetected &&
            _textController.text.trim().isNotEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "✨ ${l10n.detectedLabel} ${_getLocalizedLanguageName(context, _sourceLang)}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
