import 'dart:io';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_state.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/presentation/widgets/vision_result_card.dart'; // Updated widget
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
            return _buildResultsList(context, state.results);
          }

          if (state is VisionError) {
            return _buildErrorState(state.message);
          }

          return _buildInitialState(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildActionButtons(context),
    );
  }

  Widget _buildResultsList(BuildContext context, List<VisionResult> results) {
    if (results.isEmpty) {
      return const Center(child: Text("No data found in image."));
    }

    // Separate results for cleaner sectioning
    final barcodes = results.where((r) => r.type != VisionType.text).toList();
    final textResults = results
        .where((r) => r.type == VisionType.text)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (barcodes.isNotEmpty) ...[
          _buildHeader("Detected Codes"),
          ...barcodes.map((res) => VisionResultCard(result: res)),
          const SizedBox(height: 24),
        ],

        if (textResults.isNotEmpty) ...[
          _buildHeader("Recognized Text"),
          ...textResults.map((res) => VisionResultCard(result: res)),
        ],

        const SizedBox(height: 100), // Padding for FABs
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

  // --- Image Picking & Cropping Logic (Same as before) ---

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

  Future<void> _handlePickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source);

    if (xFile != null) {
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
          toolbarColor: const Color(0xFF364156),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
