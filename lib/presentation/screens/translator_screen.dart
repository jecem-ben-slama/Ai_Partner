import 'package:ai_partner/logic/translation/translation_cubit.dart';
import 'package:ai_partner/logic/translation/translation_state.dart';
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
  
  late TextEditingController _textController ;
  TranslateLanguage _sourceLang = TranslateLanguage.english;
  TranslateLanguage _targetLang = TranslateLanguage.spanish;
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

  // Helper to swap languages quickly
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
      backgroundColor: const Color(0xFF161925),
      appBar: AppBar(
        title: const Text(
          "AI Translator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        color: const Color(0xFF364156),
        borderRadius: BorderRadius.circular(15),
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
            icon: const Icon(Icons.swap_horiz, color: Colors.white70),
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
      dropdownColor: const Color(0xFF364156),
      style: const TextStyle(color: Colors.white, fontSize: 14),
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
        color: const Color(0xFF364156),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: 6,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: "Type or paste text here...",
          hintStyle: TextStyle(color: Colors.white24),
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "TRANSLATE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
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
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "RESULT",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (state is TranslationSuccess)
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: Colors.white38,
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
