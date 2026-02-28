import 'package:ai_partner/presentation/widgets/highlighted_text_widget.dart';
import 'package:flutter/material.dart';
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
    return BlocListener<TtsCubit, TtsState>(
      listenWhen: (prev, curr) => curr.status == TtsStatus.error,
      listener: (context, state) {
        // Using a custom method or standard Snack if you prefer,
        // but here we focus on the UI
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: BlocBuilder<TtsCubit, TtsState>(
          builder: (context, state) {
            final isPlaying = state.status == TtsStatus.playing;
            final isLoading = state.status == TtsStatus.loading;

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: isPlaying
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.5)
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(25),
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
                                  decoration: const InputDecoration(
                                    hintText: "What should I read for you?",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (state.detectedLanguage.isNotEmpty)
                  _buildLanguageBadge(state.detectedLanguage),

                _buildModernPlayerControls(context, state),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageBadge(String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Detected: ${lang.toUpperCase()}",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildModernPlayerControls(BuildContext context, TtsState state) {
    final isPlaying = state.status == TtsStatus.playing;
    final isLoading = state.status == TtsStatus.loading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(45),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            // Speed Control Column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${(state.speed * 2).toStringAsFixed(1)}x",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text(
                  "Speed",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),

            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: state.speed,
                  min: 0.1,
                  max: 1.0,
                  onChanged: isPlaying || isLoading
                      ? null
                      : (val) {
                          context.read<TtsCubit>().updateSpeed(val);
                        },
                ),
              ),
            ),

            // Modern Play/Stop Button with Text Detection
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final bool hasText = value.text.trim().isNotEmpty;
                final bool canPress = hasText && !isLoading;

                // If it is playing, we want it enabled to stop it
                final bool effectivelyEnabled = isPlaying || canPress;

                return GestureDetector(
                  onTap: effectivelyEnabled
                      ? () {
                          if (isPlaying) {
                            context.read<TtsCubit>().stop();
                          } else {
                            FocusScope.of(context).unfocus();
                            context.read<TtsCubit>().detectAndSpeak(
                              _controller.text,
                            );
                          }
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: !effectivelyEnabled
                          ? Colors.grey.withOpacity(0.3) // Greyed out state
                          : (isPlaying
                                ? Colors.redAccent
                                : Theme.of(context).colorScheme.primary),
                      shape: BoxShape.circle,
                      boxShadow: effectivelyEnabled
                          ? [
                              BoxShadow(
                                color:
                                    (isPlaying
                                            ? Colors.redAccent
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primary)
                                        .withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.stop_rounded
                                  : Icons.play_arrow_rounded,
                              color: effectivelyEnabled
                                  ? Colors.white
                                  : Colors.grey,
                              size: 38,
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
