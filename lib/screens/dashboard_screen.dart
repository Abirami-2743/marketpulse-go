import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../widgets/price_card.dart';
import '../widgets/change_bar_chart.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();

    return RefreshIndicator(
      onRefresh: () => context.read<MarketProvider>().loadAll(),
      child: market.isLoading && market.crypto.isEmpty && market.stocks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              children: [
                if (market.isShowingCachedData) _offlineBanner(context, market.cachedAt),
                if (market.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(market.errorMessage!, style: const TextStyle(color: AppColors.red)),
                  ),
                _sectionLabel(context, "Crypto"),
                if (market.crypto.isNotEmpty)
                  ChangeBarChart(title: "Crypto", items: market.crypto),
                ...market.crypto.map((item) => PriceCard(item: item)),
                if (market.crypto.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("No crypto data yet.", style: TextStyle(color: ThemeColors.textSecondary(context))),
                  ),
                const SizedBox(height: 20),
                _sectionLabel(context, "Stocks"),
                if (market.stocks.isNotEmpty)
                  ChangeBarChart(title: "Stocks", items: market.stocks),
                ...market.stocks.map((item) => PriceCard(item: item)),
                if (market.stocks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("No stock data yet.", style: TextStyle(color: ThemeColors.textSecondary(context))),
                  ),
              ],
            ),
    );
  }

  Widget _offlineBanner(BuildContext context, DateTime? cachedAt) {
    final timeText = cachedAt != null
        ? DateFormat('MMM d, h:mm a').format(cachedAt)
        : "an earlier session";

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceLight(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Offline — showing cached prices from $timeText",
              style: TextStyle(color: ThemeColors.textSecondary(context), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ThemeColors.textPrimary(context),
        ),
      ),
    );
  }
}