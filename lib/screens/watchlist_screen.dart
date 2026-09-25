import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/price_card.dart';
import '../theme/theme_colors.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final textSecondary = ThemeColors.textSecondary(context);
    final textPrimary = ThemeColors.textPrimary(context);

    final allItems = [...market.crypto, ...market.stocks];
    final watchedItems =
        allItems.where((item) => watchlist.isWatched(item.symbol)).toList();

    if (market.isLoading && allItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (watchedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "Your watchlist is empty.\nTap the star on any asset in the Dashboard to add it here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            "Watchlist",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ),
        ...watchedItems.map((item) => PriceCard(item: item)),
      ],
    );
  }
}