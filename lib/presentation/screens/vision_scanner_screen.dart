import 'dart:io';
import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_cubit.dart';
import 'package:ai_partner/logic/cubit/scanning/vision_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              context.read<VisionCubit>().reset();
            },
          ),
        ],
      ),
      body: BlocBuilder<VisionCubit, VisionState>(
        builder: (context, state) {
          if (state is VisionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VisionSuccess) return _buildResultsList(state.results);
          if (state is VisionError) {
            return _buildErrorState(context, state.message);
          }
          return _buildInitialState(context, l10n);
        },
      ),
      bottomNavigationBar: SafeArea(child: _buildActionPod(context, l10n)),
    );
  }

  Widget _buildInitialState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Text(l10n.textExtractionLabel, textAlign: TextAlign.center),
    );
  }

  Widget _buildResultsList(List<VisionResult> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) => VisionResultCard(result: results[index]),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget _buildActionPod(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _podItem(
            context,
            Icons.camera_alt,
            l10n.cameraLabel,
            () => _handlePickImage(context, ImageSource.camera, l10n),
          ),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          _podItem(
            context,
            Icons.photo_library,
            l10n.galleryLabel,
            () => _handlePickImage(context, ImageSource.gallery, l10n),
          ),
        ],
      ),
    );
  }

  Widget _podItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _handlePickImage(
    BuildContext context,
    ImageSource source,
    AppLocalizations l10n,
  ) async {
    final xFile = await ImagePicker().pickImage(source: source);
    if (xFile != null && context.mounted) {
      final cropped = await _cropImage(xFile.path, context);
      if (cropped != null && context.mounted) {
        // Passing required localized messages
        context.read<VisionCubit>().scanImage(
          imageFile: File(cropped.path),
          emptyMessage: l10n.nothingFound,
          errorMessage: l10n.visionError,
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path, BuildContext context) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(context)!.selectZoneLabel,
        ),
        IOSUiSettings(title: AppLocalizations.of(context)!.selectZoneLabel),
      ],
    );
  }
}
