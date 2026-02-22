import 'package:ai_partner/presentation/screens/vision_scanner_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          children: [
            const Text(
              "Welcome to AI Partner!\n\nUse the bottom navigation to explore features.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisionScannerScreen(),
                  ),
                );
              },
              child: const Text("Text Extraction"),
            ),
          ],
        ),
      ),
    );
  }
}
