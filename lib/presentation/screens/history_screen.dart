import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/logic/cubit/storage/history_state.dart';
import 'package:ai_partner/logic/services/haptic_service.dart';
import 'package:ai_partner/presentation/widgets/history_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
              context.read<HapticService>().triggerSuccess();

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
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HistoryLoaded) {
                  if (state.savedScans.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  // Efficiently filter results
                  final filteredScans = state.savedScans.where((scan) {
                    final results = scan['results'] as List? ?? [];
                    final firstResult = results.isNotEmpty ? results.first : {};

                    final bool isFav = firstResult['isFavorite'] == true;
                    final bool matchesFavoriteFilter =
                        !_showOnlyFavorites || isFav;

                    final String label =
                        firstResult['label']?.toString().toLowerCase() ?? "";
                    final String content =
                        firstResult['content']?.toString().toLowerCase() ?? "";
                    final bool matchesSearch =
                        label.contains(_searchQuery.toLowerCase()) ||
                        content.contains(_searchQuery.toLowerCase());

                    return matchesFavoriteFilter && matchesSearch;
                  }).toList();

                  if (filteredScans.isEmpty) {
                    return _buildNoResultsState(l10n);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredScans.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final scan = filteredScans[index];
                      return HistoryItemCard(
                        key: ValueKey(scan['id']),
                        scan: scan,
                      );
                    },
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
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              label: l10n.allscansLabel,
              isActive: !_showOnlyFavorites,
              onTap: () {
                setState(() => _showOnlyFavorites = false);
                context.read<HapticService>().trigger();
              },
            ),
            _filterTile(
              label: l10n.favoritesLabel,
              isActive: _showOnlyFavorites,
              onTap: () {
                setState(() => _showOnlyFavorites = true);
                context.read<HapticService>().trigger();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTile({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
                fontSize: 13,
                color: isActive ? colorScheme.onPrimary : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.nothingFound,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.nothingFound, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().clearAll(
                errorMessage: l10n.clearHistoryError,
              );
              Navigator.pop(dialogContext);
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
