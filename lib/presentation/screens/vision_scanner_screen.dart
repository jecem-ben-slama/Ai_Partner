import 'dart:io';
import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_state.dart';
import 'package:ai_partner/models/scan_result_model.dart';
import 'package:ai_partner/presentation/widgets/vision_result_card.dart';
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
          ...barcodes.map((res) => VisionResultCard(result: res)),
          const SizedBox(height: 24),
        ],

        if (textResults.isNotEmpty) ...[
          ...textResults.map((res) => VisionResultCard(result: res)),
        ],

        const SizedBox(height: 100), // Padding for FABs
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: AppLocalizations.of(context)!.cameraLabel,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Theme.of(context).colorScheme.primary,
              onPressed: () => _handlePickImage(context, ImageSource.camera),
              label: Text(AppLocalizations.of(context)!.cameraLabel),
              icon: const Icon(Icons.camera_alt),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FloatingActionButton.extended(
              heroTag: AppLocalizations.of(context)!.galleryLabel,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Theme.of(context).colorScheme.primary,
              onPressed: () => _handlePickImage(context, ImageSource.gallery),
              label: Text(AppLocalizations.of(context)!.galleryLabel),
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
      if (context.mounted) {
        final croppedFile = await _cropImage(xFile.path, context);
        if (croppedFile != null && context.mounted) {
          context.read<VisionCubit>().scanImage(File(croppedFile.path));
        }
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path, BuildContext context) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(context)!.selectZoneLabel,
          toolbarColor: const Color(0xFF364156),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: AppLocalizations.of(context)!.selectZoneLabel),
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
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.textExtractionLabel),
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
