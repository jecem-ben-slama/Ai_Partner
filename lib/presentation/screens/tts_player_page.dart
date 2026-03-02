import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/presentation/widgets/highlighted_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/tts/tts_cubit.dart';
import '../../logic/cubit/tts/tts_state.dart';

class TtsPlayerPage extends StatefulWidget {
  final String? text;
  const TtsPlayerPage({super.key, this.text});

  @override
  State<TtsPlayerPage> createState() => _TtsPlayerPageState();
}

class _TtsPlayerPageState extends State<TtsPlayerPage> {
  late TextEditingController _controller;
  late TtsCubit _ttsCubit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _ttsCubit = context.read<TtsCubit>();
  }

  @override
  void dispose() {
    _ttsCubit.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded),
            onPressed: () => setState(() => _controller.clear()),
          ),
        ],
      ),
      body: BlocBuilder<TtsCubit, TtsState>(
        builder: (context, state) {
          final isPlaying = state.status == TtsStatus.playing;
          final isLoading = state.status == TtsStatus.loading;
          final isError = state.status == TtsStatus.error;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Column(
                        children: [
                          if (isError) _buildErrorBanner(state.errorMessage),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: isPlaying
                                  ? HighlightedText(
                                      fullText: _controller.text,
                                      start: state.start,
                                      end: state.end,
                                    )
                                  : TextField(
                                      controller: _controller,
                                      maxLines: null,
                                      enabled: !isPlaying && !isLoading,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.6,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: l10n.textHint,
                                        border: InputBorder.none,
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.detectedLanguage.isNotEmpty && !isError)
                _buildLanguageBadge(state.detectedLanguage, l10n),
              const SizedBox(height: 10),
              _buildModernPlayerControls(context, state, l10n),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageBadge(String lang, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        " ${l10n.detectedLabel} ${lang.toUpperCase()}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildModernPlayerControls(
    BuildContext context,
    TtsState state,
    AppLocalizations l10n,
  ) {
    final isPlaying = state.status == TtsStatus.playing;
    final isLoading = state.status == TtsStatus.loading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${(state.speed * 2).toStringAsFixed(1)}x",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  l10n.speedLabel,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: state.speed,
                  min: 0.1,
                  max: 1.0,
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.blueGrey,
                  onChanged: isPlaying || isLoading
                      ? null
                      : (val) => context.read<TtsCubit>().updateSpeed(val),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final bool hasText = value.text.trim().isNotEmpty;
                final bool canPress = hasText && !isLoading;
                final bool effectivelyEnabled = isPlaying || canPress;

                return GestureDetector(
                  onTap: effectivelyEnabled
                      ? () {
                          if (isPlaying) {
                            context.read<TtsCubit>().stop();
                          } else {
                            FocusScope.of(context).unfocus();
                            HapticFeedback.lightImpact();
                            context.read<TtsCubit>().detectAndSpeak(
                              _controller.text,
                            );
                          }
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: !effectivelyEnabled
                          ? Colors.grey[300]
                          : (isPlaying ? Colors.redAccent : Colors.blueAccent),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.stop_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
