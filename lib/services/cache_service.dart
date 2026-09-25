import 'package:hive_flutter/hive_flutter.dart';
import '../models/market_models.dart';

/// Hive-based local cache for market data. Lets the Dashboard keep
/// showing the last known crypto/stock prices when the device has
/// no network connection, instead of an empty or broken screen.
class CacheService {
  static const _cryptoBox = 'cache_crypto';
  static const _stocksBox = 'cache_stocks';
  static const _metaBox = 'cache_meta';
  static const _cryptoTimestampKey = 'crypto_cached_at';
  static const _stocksTimestampKey = 'stocks_cached_at';
    static Future<void> clearAll() async {
    await Hive.box(_cryptoBox).clear();
    await Hive.box(_stocksBox).clear();
    await Hive.box(_metaBox).clear();
  }

  /// Call once, before runApp().
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_cryptoBox);
    await Hive.openBox(_stocksBox);
    await Hive.openBox(_metaBox);
  }

  static Future<void> saveCrypto(List<PriceItem> items) async {
    final box = Hive.box(_cryptoBox);
    await box.put('items', items.map((e) => e.raw).toList());
    await Hive.box(_metaBox).put(_cryptoTimestampKey, DateTime.now().toIso8601String());
  }

  static Future<void> saveStocks(List<PriceItem> items) async {
    final box = Hive.box(_stocksBox);
    await box.put('items', items.map((e) => e.raw).toList());
    await Hive.box(_metaBox).put(_stocksTimestampKey, DateTime.now().toIso8601String());
  }

  static List<PriceItem> getCachedCrypto() {
    final raw = Hive.box(_cryptoBox).get('items');
    if (raw == null) return [];
    return (raw as List)
        .map((e) => PriceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<PriceItem> getCachedStocks() {
    final raw = Hive.box(_stocksBox).get('items');
    if (raw == null) return [];
    return (raw as List)
        .map((e) => PriceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Most recent of the two cache timestamps, for display in the UI.
  static DateTime? getLastCachedAt() {
    final meta = Hive.box(_metaBox);
    final cryptoStr = meta.get(_cryptoTimestampKey);
    final stocksStr = meta.get(_stocksTimestampKey);
    final crypto = cryptoStr == null ? null : DateTime.tryParse(cryptoStr);
    final stocks = stocksStr == null ? null : DateTime.tryParse(stocksStr);
    if (crypto == null) return stocks;
    if (stocks == null) return crypto;
    return crypto.isAfter(stocks) ? crypto : stocks;
  }
}