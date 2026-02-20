import 'dart:io';
import 'package:ai_partner/logic/text/text_cubit.dart';
import 'package:ai_partner/logic/text/text_state.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextRecognitionScreen extends StatelessWidget {
  const TextRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Scanner")),
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
                      ? SelectableText(
                          state.text,
                        ) // Allows user to copy the text
                      : const Center(
                          child: Text("Pick an image to start scanning"),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Space for FloatingNavbar
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Scan Image"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<TextCubit>().recognizeText(File(image.path));
    }
  }
}
