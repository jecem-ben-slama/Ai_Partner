import 'package:ai_partner/l10n/app_localizations.dart';
import 'package:ai_partner/logic/cubit/storage/history_cubit.dart';
import 'package:ai_partner/logic/cubit/storage/history_state.dart';
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
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showDeleteConfirm(context, l10n),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          _buildFilterTabs(),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HistoryLoaded) {
                  final filteredScans = state.savedScans.where((scan) {
                    final results = scan['results'] as List;
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

                  if (state.savedScans.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  if (filteredScans.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 80,
                    ),
                    itemCount: filteredScans.length,
                    itemBuilder: (context, index) {
                      final scan = filteredScans[index];
                      return Padding(
                        key: ValueKey(scan['id']),
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            HistoryItemCard(scan: scan),
                            const Divider(),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text("Unable to load history"));
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
          hintText: "Search saved items...",
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterTile(
            label: "All Scans",
            icon: Icons.list_alt_rounded,
            isActive: !_showOnlyFavorites,
            onTap: () => setState(() => _showOnlyFavorites = false),
          ),
          const SizedBox(width: 12),
          _filterTile(
            label: "Favorites",
            icon: Icons.favorite_rounded,
            isActive: _showOnlyFavorites,
            onTap: () => setState(() => _showOnlyFavorites = true),
          ),
        ],
      ),
    );
  }

  Widget _filterTile({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.grey,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.primary,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? colorScheme.onPrimary : Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isActive ? colorScheme.onPrimary : Colors.white54,
                ),
              ),
            ],
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
          const Icon(Icons.history_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            "No saved scans yet",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyFavorites ? Icons.heart_broken_outlined : Icons.search_off,
            size: 48,
            color: Colors.white10,
          ),
          const SizedBox(height: 16),
          const Text(
            "No matches found",
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearHistoryTitle),
        content: Text(l10n.clearHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().clearAll();
              Navigator.pop(dialogContext);
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
