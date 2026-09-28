import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

const _fullNames = {
  "BTC": "Bitcoin",
  "ETH": "Ethereum",
  "BNB": "BNB (Binance)",
  "SOL": "Solana",
  "TSLA": "Tesla",
  "MSFT": "Microsoft",
  "GOOGL": "Google (Alphabet)",
  "AAPL": "Apple",
};

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  bool _showCrypto = true;

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final source = _showCrypto ? market.crypto : market.stocks;
    final ranked = [...source]
      ..sort((a, b) =>
          (b.changePercent24h ?? 0).compareTo(a.changePercent24h ?? 0));

    if (market.isLoading && market.crypto.isEmpty && market.stocks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MarketProvider>().loadAll(),
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: true,
                    label: Text("Crypto"),
                    icon: Icon(Icons.currency_bitcoin)),
                ButtonSegment(
                    value: false,
                    label: Text("Stocks"),
                    icon: Icon(Icons.show_chart)),
              ],
              selected: {_showCrypto},
              onSelectionChanged: (s) => setState(() => _showCrypto = s.first),
            ),
          ),
          const SizedBox(height: 12),
          _infoCard(context),
          const SizedBox(height: 4),
          _RankingList(
            key: ValueKey(_showCrypto),
            items: ranked,
            isLoading: market.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceLight(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "New to markets? Assets are ranked by how much their price "
              "moved in the last 24 hours. #1 did the best today. "
              "Green means the price went up, red means it went down.",
              style: TextStyle(
                  color: ThemeColors.textSecondary(context), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingList extends StatefulWidget {
  final List<PriceItem> items;
  final bool isLoading;
  const _RankingList({super.key, required this.items, required this.isLoading});

  @override
  State<_RankingList> createState() => _RankingListState();
}

class _RankingListState extends State<_RankingList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  String _sig(List<PriceItem> l) =>
      l.map((e) => '${e.symbol}:${e.price}:${e.changePercent24h}').join('|');

  @override
  void didUpdateWidget(covariant _RankingList old) {
    super.didUpdateWidget(old);
    final loadFinished = old.isLoading && !widget.isLoading;
    if (loadFinished || _sig(old.items) != _sig(widget.items)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _itemAnim(int i, int n) {
    final start = n <= 1 ? 0.0 : (i / n) * 0.45;
    final end = (start + 0.55).clamp(0.0, 1.0);
    return CurveTween(curve: Interval(start, end, curve: Curves.easeOutCubic))
        .animate(_c);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text("No data yet. Pull down to refresh.",
              style: TextStyle(color: ThemeColors.textSecondary(context))),
        ),
      );
    }

    final maxAbs = items
        .map((e) => (e.changePercent24h ?? 0).abs())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        _TopBanner(
          item: items.first,
          anim: CurveTween(curve: const Interval(0, 0.5, curve: Curves.elasticOut))
              .animate(_c),
        ),
        ...List.generate(
          items.length,
          (i) => _RankRow(
            item: items[i],
            rank: i + 1,
            maxAbs: maxAbs,
            anim: _itemAnim(i, items.length),
          ),
        ),
      ],
    );
  }
}

class _TopBanner extends StatelessWidget {
  final PriceItem item;
  final Animation<double> anim;
  const _TopBanner({required this.item, required this.anim});

  @override
  Widget build(BuildContext context) {
    final change = item.changePercent24h ?? 0;
    final name = _fullNames[item.symbol] ?? item.symbol;
    final subtitle = change >= 0
        ? "Best performer in the last 24 hours"
        : "Everything is down today. This one fell the least";

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final v = anim.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + 0.15 * v,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.35),
                    AppColors.accent.withOpacity(0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.accent, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("#1  $name (${item.symbol})",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: ThemeColors.textPrimary(context))),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: ThemeColors.textSecondary(context))),
                      ],
                    ),
                  ),
                  Text(
                    "${change >= 0 ? '+' : ''}${(change * v).toStringAsFixed(2)}%",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: change >= 0 ? AppColors.green : AppColors.red),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RankRow extends StatelessWidget {
  final PriceItem item;
  final int rank;
  final double maxAbs;
  final Animation<double> anim;

  const _RankRow({
    required this.item,
    required this.rank,
    required this.maxAbs,
    required this.anim,
  });

  Color _badgeColor(BuildContext context) {
    switch (rank) {
      case 1:
        return AppColors.accent;
      case 2:
        return const Color(0xFFC0C6CE);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return ThemeColors.surfaceLight(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final change = item.changePercent24h ?? 0;
    final isUp = change >= 0;
    final color = isUp ? AppColors.green : AppColors.red;
    final frac = maxAbs == 0 ? 0.03 : (change.abs() / maxAbs).clamp(0.03, 1.0);
    final name = _fullNames[item.symbol] ?? item.symbol;
    final textPrimary = ThemeColors.textPrimary(context);
    final textSecondary = ThemeColors.textSecondary(context);

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final v = anim.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset((1 - v) * 40, 0),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: rank == 1
                    ? BorderSide(
                        color: AppColors.accent.withOpacity(0.6), width: 1.5)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _badgeColor(context), shape: BoxShape.circle),
                      child: Text("$rank",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: rank <= 3 ? Colors.black : textPrimary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(item.symbol,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textPrimary)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12, color: textSecondary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                Container(
                                    height: 8,
                                    color: ThemeColors.surfaceLight(context)),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (frac * v).clamp(0.0, 1.0),
                                  child: Container(height: 8, color: color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${isUp ? '+' : ''}${(change * v).toStringAsFixed(2)}%",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: color),
                        ),
                        const SizedBox(height: 4),
                        Text("\$${item.price.toStringAsFixed(2)}",
                            style:
                                TextStyle(fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}