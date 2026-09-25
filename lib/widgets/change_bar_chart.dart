import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/market_models.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class ChangeBarChart extends StatelessWidget {
  final String title;
  final List<PriceItem> items;

  const ChangeBarChart({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final textPrimary = ThemeColors.textPrimary(context);
    final textSecondary = ThemeColors.textSecondary(context);
    final surfaceLight = ThemeColors.surfaceLight(context);

    final values = items.map((e) => e.changePercent24h ?? 0).toList();
    final maxAbs = values.map((v) => v.abs()).fold<double>(0, (a, b) => a > b ? a : b);
    final axisMax = (maxAbs == 0 ? 1 : maxAbs) * 1.4;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title — 24h % Change",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  minY: -axisMax,
                  maxY: axisMax,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: axisMax / 2,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: surfaceLight,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          "${value.toStringAsFixed(1)}%",
                          style: TextStyle(color: textSecondary, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= items.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              items[i].symbol,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(items.length, (i) {
                    final change = items[i].changePercent24h ?? 0;
                    final isUp = change >= 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: change,
                          color: isUp ? AppColors.green : AppColors.red,
                          width: 28,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: surfaceLight,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = items[group.x.toInt()];
                        return BarTooltipItem(
                          "${item.symbol}\n${rod.toY.toStringAsFixed(2)}%",
                          TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}