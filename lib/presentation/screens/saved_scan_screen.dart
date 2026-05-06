import 'package:ai_partner/core/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_cubit.dart';
import 'package:ai_partner/logic/cubit/saved_scan/saved_scan_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/logic/services/sound_service.dart';
import 'package:ai_partner/presentation/widgets/saved_scan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedScanScreen extends StatefulWidget {
  const SavedScanScreen({super.key});

  @override
  State<SavedScanScreen> createState() => _SavedScanScreenState();
}

class _SavedScanScreenState extends State<SavedScanScreen> {
  String _searchQuery = "";
  bool _showOnlyFavorites = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Colors.redAccent,
            ),
            onPressed: () {
              context.read<SoundService>().playTap();
              context.read<HapticService>().trigger();
              _showDeleteConfirm(context, l10n);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          _buildFilterTabs(l10n),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<SavedScanCubit, SavedScanState>(
              builder: (context, state) {
                if (state is SavedScanLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SavedScanLoaded) {
                  if (state.savedScans.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  // filtering using the VisionResult model
                  final filteredScans = state.savedScans.where((scan) {
                    final bool matchesFavoriteFilter =
                        !_showOnlyFavorites || scan.isFavorite;
                    final String label = (scan.label ?? "").toLowerCase();
                    final String content = scan.content.toLowerCase();
                    final bool matchesSearch =
                        label.contains(_searchQuery.toLowerCase()) ||
                        content.contains(_searchQuery.toLowerCase());
                    return matchesFavoriteFilter && matchesSearch;
                  }).toList();

                  if (filteredScans.isEmpty) return _buildNoResultsState(l10n);

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredScans.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => SavedScanCard(
                      key: ValueKey(filteredScans[index].id),
                      scan: filteredScans[index],
                    ),
                  );
                }
                return Center(child: Text(l10n.loadHistoryError));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: l10n.searchLabel,
          prefixIcon: const Icon(Icons.search, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _filterTile(
              l10n.allscansLabel,
              !_showOnlyFavorites,
              () => setState(() => _showOnlyFavorites = false),
            ),
            _filterTile(
              l10n.favoritesLabel,
              _showOnlyFavorites,
              () => setState(() => _showOnlyFavorites = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTile(String label, bool isActive, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<SoundService>().playTap();
          context.read<HapticService>().trigger();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? colorScheme.onPrimary : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.history_rounded, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(l10n.nothingFound),
      ],
    ),
  );

  Widget _buildNoResultsState(AppLocalizations l10n) =>
      Center(child: Text(l10n.nothingFound));

  void _showDeleteConfirm(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<SavedScanCubit>().clearAll(
                errorMessage: l10n.clearHistoryError,
              ); // Passing required param
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
