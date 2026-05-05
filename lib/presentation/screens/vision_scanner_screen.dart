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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              context.read<VisionCubit>().reset();
            },
            tooltip: l10n.resetTitle,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: BlocBuilder<VisionCubit, VisionState>(
          builder: (context, state) {
            if (state is VisionLoading) {
              return _buildLoadingState(context, l10n);
            }

            if (state is VisionSuccess) {
              return _buildResultsList(context, state.results, l10n);
            }

            if (state is VisionError) {
              return _buildErrorState(context, state.message, colorScheme);
            }

            return _buildInitialState(context, l10n);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildActionPod(context, l10n)),
    );
  }

  Widget _buildInitialState(BuildContext context, AppLocalizations l10n) {
    return Center(
      key: const ValueKey('initial'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              Icons.document_scanner_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.textExtractionLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            l10n.analysingLabel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<VisionResult> results,
    AppLocalizations l10n,
  ) {
    if (results.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.nothingFound,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final barcodes = results.where((r) => r.type != VisionType.text).toList();
    final textResults = results
        .where((r) => r.type == VisionType.text)
        .toList();

    return ListView(
      key: const ValueKey('results'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (barcodes.isNotEmpty) ...[
          ...barcodes.map((res) => VisionResultCard(result: res)),
          const SizedBox(height: 20),
        ],
        if (textResults.isNotEmpty) ...[
          ...textResults.map((res) => VisionResultCard(result: res)),
        ],
        const SizedBox(height: 40), // Bottom padding
      ],
    );
  }

  /// 4. Error State
  Widget _buildErrorState(
    BuildContext context,
    String message,
    ColorScheme colorScheme,
  ) {
    return Center(
      key: const ValueKey('error'),
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 5. The Modern Action Pod (Bottom Bar)
  Widget _buildActionPod(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          _buildPodItem(
            context,
            icon: Icons.camera_alt_rounded,
            label: l10n.cameraLabel,
            onPressed: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              _handlePickImage(context, ImageSource.camera, l10n);
            },
          ),
          VerticalDivider(width: 1, indent: 20, endIndent: 20),
          _buildPodItem(
            context,
            icon: Icons.photo_library_rounded,
            label: l10n.galleryLabel,
            onPressed: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              _handlePickImage(context, ImageSource.gallery, l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPodItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Theme.of(context).colorScheme.primary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Image Logic (Picker & Cropper)
  Future<void> _handlePickImage(
    BuildContext context,
    ImageSource source,
    AppLocalizations l10n,
  ) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source);

    if (xFile != null) {
      if (context.mounted) {
        final croppedFile = await _cropImage(xFile.path, context);
        if (croppedFile != null && context.mounted) {
          context.read<VisionCubit>().scanImage(
            imageFile: File(croppedFile.path),
            emptyMessage: l10n.emptyVision,
            errorMessage: l10n.visionError,
          );
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
}
