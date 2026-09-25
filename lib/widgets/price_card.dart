import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/market_models.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class PriceCard extends StatelessWidget {
  final PriceItem item;
  const PriceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final change = item.changePercent24h ?? 0;
    final isUp = change >= 0;
    final changeColor = isUp ? AppColors.green : AppColors.red;
    final watchlist = context.watch<WatchlistProvider>();
    final isWatched = watchlist.isWatched(item.symbol);
    final textPrimary = ThemeColors.textPrimary(context);
    final textSecondary = ThemeColors.textSecondary(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.symbol.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (item.changePercent24h != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isUp ? Icons.trending_up : Icons.trending_down,
                          color: changeColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${change.toStringAsFixed(2)}%",
                          style: TextStyle(color: changeColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isWatched ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isWatched ? AppColors.accent : textSecondary,
                  ),
                  onPressed: () => context.read<WatchlistProvider>().toggle(item.symbol),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}