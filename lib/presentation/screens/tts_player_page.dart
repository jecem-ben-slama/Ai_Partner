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
  // 1. Create a local variable to hold the reference
  late TtsCubit _ttsCubit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    // 2. Grab the reference immediately
    _ttsCubit = context.read<TtsCubit>();
  }

  @override
  void dispose() {
    // 3. Use the local reference instead of context.read
    _ttsCubit.stop();
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<TtsCubit, TtsState>(
      // Listen for errors to show a SnackBar
      listenWhen: (prev, curr) => curr.status == TtsStatus.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "AI Narrator",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TtsCubit, TtsState>(
          builder: (context, state) {
            final isPlaying = state.status == TtsStatus.playing;
            final isLoading = state.status == TtsStatus.loading;

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: state.status == TtsStatus.error
                              ? Colors.red.withOpacity(0.5)
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
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
                                enabled:
                                    !isPlaying &&
                                    !isLoading, // Disable editing while playing/loading
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.6,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Enter or edit text here...",
                                  border: InputBorder.none,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Detection Badge
                if (state.detectedLanguage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Chip(
                      label: Text("Detected: ${state.detectedLanguage}"),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  ),

                _buildModernControls(context, state),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernControls(BuildContext context, TtsState state) {
    final isPlaying = state.status == TtsStatus.playing;
    final isLoading = state.status == TtsStatus.loading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              "${(state.speed * 2).toStringAsFixed(1)}x",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
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

            // FAB-style Main Action Button
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      if (isPlaying) {
                        context.read<TtsCubit>().stop();
                      } else {
                        FocusScope.of(context).unfocus();
                        context.read<TtsCubit>().detectAndSpeak(
                          _controller.text,
                        );
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey
                      : (isPlaying
                            ? Colors.redAccent
                            : Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(isPlaying ? 16 : 28),
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
            ),
          ],
        ),
      ),
    );
  }
}
