import 'dart:io';
import 'package:ai_partner/logic/text/text_cubit.dart';
import 'package:ai_partner/logic/text/text_state.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class TextRecognitionScreen extends StatelessWidget {
  const TextRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the theme for consistent styling
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Universal AI Scanner"),
        centerTitle: true,
      ),
      body: BlocBuilder<TextCubit, TextState>(
        builder: (context, state) {
          if (state is TextLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: state is TextSuccess
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. QR Code / Barcode Section
                            if (state.barcodes.isNotEmpty) ...[
                              _buildBarcodeCard(context, state.barcodes.first),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 10),
                            ],

                            // 2. Extracted Text Section
                            Text(
                              "Detected Text:",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            SelectableText(
                              state.recognizedText ?? "No readable text found.",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        )
                      : _buildEmptyState(context),
                ),
              ),

              // 3. Action Buttons
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () =>
                            _pickImage(context, ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Camera"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () =>
                            _pickImage(context, ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Gallery"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // A special card for QR results using your custom 0xFF364156
  Widget _buildBarcodeCard(BuildContext context, dynamic barcode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // This is your 0xFF364156
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              const Text(
                "QR Code Detected",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(barcode.displayValue),
          const SizedBox(height: 10),
          if (barcode.displayValue.startsWith("http"))
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(barcode.displayValue)),
              child: const Text("Open Link"),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.center_focus_weak,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          const Text("Point at text or a QR code to begin"),
        ],
      ),
    );
  }

 Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality:
            80, // Reduces memory usage to prevent crashes on mid-range phones
      );

      // FIX: Check if the user cancelled or if the image is null BEFORE calling the Cubit
      if (image == null) {
        debugPrint("User cancelled image picking");
        return;
      }

      // Ensure the widget is still mounted before using context.read
      if (!context.mounted) return;

      final file = File(image.path);
      context.read<TextCubit>().scanImage(file);
    } catch (e) {
      debugPrint("Error picking image: $e");
      // Optionally show a SnackBar here
    }
  }
}
