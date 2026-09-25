import 'package:hive_flutter/hive_flutter.dart';

/// Hive-based persistence for the user's watchlisted asset symbols.
class WatchlistService {
  static const _watchlistBox = 'watchlist';
  static const _key = 'symbols';

  /// Call once, before runApp() — alongside CacheService.init().
  static Future<void> init() async {
    await Hive.openBox(_watchlistBox);
  }

  static List<String> getSymbols() {
    final box = Hive.box(_watchlistBox);
    final raw = box.get(_key);
    if (raw == null) return [];
    return List<String>.from(raw);
  }

  static Future<void> addSymbol(String symbol) async {
    final box = Hive.box(_watchlistBox);
    final current = getSymbols();
    if (!current.contains(symbol)) {
      current.add(symbol);
      await box.put(_key, current);
    }
  }

  static Future<void> removeSymbol(String symbol) async {
    final box = Hive.box(_watchlistBox);
    final current = getSymbols();
    current.remove(symbol);
    await box.put(_key, current);
  }
}