/// Price document returned from /market/crypto and /market/stocks.
/// Matches the exact fields written by services/data_fetcher.py:
///   crypto: { asset, price, change_24h (number), timestamp }
///   stocks: { asset, price, change_percent (string like "+0.37%"), timestamp }
class PriceItem {
  final String symbol;
  final double price;
  final double? changePercent24h;
  final String? timestamp;
  final Map<String, dynamic> raw;

  PriceItem({
    required this.symbol,
    required this.price,
    this.changePercent24h,
    this.timestamp,
    required this.raw,
  });

  factory PriceItem.fromJson(Map<String, dynamic> json) {
    return PriceItem(
      symbol: _friendlySymbol((json["asset"] ?? "—").toString()),
      price: _toDouble(json["price"]),
      changePercent24h: _parseChange(json["change_24h"] ?? json["change_percent"]),
      timestamp: json["timestamp"]?.toString(),
      raw: json,
    );
  }

  static String _friendlySymbol(String asset) {
    const map = {
      "bitcoin": "BTC",
      "ethereum": "ETH",
      "binancecoin": "BNB",
      "solana": "SOL",
    };
    return map[asset.toLowerCase()] ?? asset.toUpperCase();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static double? _parseChange(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final cleaned = v.toString().replaceAll("%", "").replaceAll("+", "").trim();
    return double.tryParse(cleaned);
  }
}

class MarketResult {
  final List<PriceItem> items;
  MarketResult({required this.items});
}