import 'dart:io';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_state.dart';
import 'package:ai_partner/presentation/widgets/barcode_card.dart';
import 'package:ai_partner/presentation/widgets/textresult_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class VisionScannerScreen extends StatelessWidget {
  const VisionScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Universal Vision"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<VisionCubit>().reset(),
          ),
        ],
      ),
      body: BlocBuilder<VisionCubit, VisionState>(
        builder: (context, state) {
          if (state is VisionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VisionSuccess) {
            return _buildResultsList(context, state);
          }

          if (state is VisionError) {
            return _buildErrorState(state.message);
          }

          return _buildInitialState(context);
        },
      ),
      // Floating Action Buttons for Camera/Gallery
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionButtons(context),
    );
  }

  Widget _buildResultsList(BuildContext context, VisionSuccess state) {
    if (state.isEmpty) {
      return const Center(child: Text("No data found in image."));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Barcode/QR Section
        if (state.barcodes.isNotEmpty) ...[
          _buildHeader("Actions Found"),
          ...state.barcodes.map((b) => BarcodeCard(barcode: b)),
          const SizedBox(height: 24),
        ],

        // 2. OCR Text Section
        if (state.fullText != null) ...[
          _buildHeader("Extracted Text"),
          TextResultCard(text: state.fullText!),
        ],

        const SizedBox(height: 100), // Padding for FAB
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "camera",
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => _handlePickImage(context, ImageSource.camera),
              label: const Text("Camera"),
              icon: const Icon(Icons.camera_alt),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: "gallery",
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () => _handlePickImage(context, ImageSource.gallery),
              label: const Text("Gallery"),
              icon: const Icon(Icons.photo_library),
            ),
          ),
          
        ],
      ),
    );
  }

  // Inside your VisionScannerScreen class

  Future<void> _handlePickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source);

    if (xFile != null) {
      // NEW: Open the cropper before scanning
      final croppedFile = await _cropImage(xFile.path, context);

      if (croppedFile != null && context.mounted) {
        context.read<VisionCubit>().scanImage(File(croppedFile.path));
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path, BuildContext context) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Select Zone',
          toolbarColor: const Color(0xFF364156), // Your custom blue
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Theme.of(
            context,
          ).colorScheme.primary, // Lavender
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false, // Allow free selection
        ),
        IOSUiSettings(title: 'Select Zone'),
      ],
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text("Upload an image to identify text or QR codes"),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text("Error: $message", style: const TextStyle(color: Colors.red)),
    );
  }
}
