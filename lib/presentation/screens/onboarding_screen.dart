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
        // 1. INPUT: Vision
        PageViewModel(
          title: "AI Recognition",
          body: "Point your camera to identify objects and text in real-time.",
          image: const Center(
            child: Icon(Icons.visibility, size: 100, color: Colors.blue),
          ),
        ),

        // 2. PROCESSING: Translation
        PageViewModel(
          title: "Smart Translation",
          body:
              "Instantly translate scanned text between English, French, and Arabic.",
          image: const Center(
            child: Icon(Icons.translate, size: 100, color: Colors.orange),
          ),
        ),

        // 3. OUTPUT: TTS
        PageViewModel(
          title: "Listen & Learn",
          body:
              "Let your AI partner read translations out loud with natural voices.",
          image: const Center(
            child: Icon(
              Icons.record_voice_over,
              size: 100,
              color: Colors.green,
            ),
          ),
        ),

        // 4. VALUE PROP: Offline
        PageViewModel(
          title: "Always Offline",
          body:
              "No internet? No problem. All AI models run directly on your device.",
          image: const Center(
            child: Icon(Icons.wifi_off, size: 100, color: Colors.redAccent),
          ),
        ),

        // 5. PRIVACY: Data Safety
        PageViewModel(
          title: "Privacy First",
          body: "Your data never leaves your phone. Safe, secure, and private.",
          image: const Center(
            child: Icon(Icons.security, size: 100, color: Colors.teal),
          ),
        ),
      ],
      onDone: () {
        context.read<SettingsCubit>().completeOnboarding();
      },
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      done: const Text(
        "Get Started",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).primaryColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
