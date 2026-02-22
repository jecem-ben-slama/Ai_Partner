import 'package:ai_partner/logic/cubit/settings/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "AI Recognition",
          body: "Identify objects and text in real-time.",
          image: const Center(child: Icon(Icons.psychology, size: 100)),
        ),
        PageViewModel(
          title: "Offline Functionality",
          body: "Works without an internet connection.",
          image: const Center(child: Icon(Icons.wifi_off, size: 100)),
        ),
        PageViewModel(
          title: "Multi-language",
          body: "Support for French, English, and Arabic.",
          image: const Center(child: Icon(Icons.translate, size: 100)),
        ),
      ],
      onDone: () {
        context.read<SettingsCubit>().completeOnboarding();
      },
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
