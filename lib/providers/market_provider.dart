import 'package:flutter/foundation.dart';
import '../models/market_models.dart';
import '../services/market_service.dart';
import '../services/cache_service.dart';

class MarketProvider extends ChangeNotifier {
  final MarketService _marketService = MarketService();

  List<PriceItem> crypto = [];
  List<PriceItem> stocks = [];
  bool isLoading = false;
  String? errorMessage;
  bool isShowingCachedData = false;
  DateTime? cachedAt;

  Future<void> loadAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _marketService.getCrypto(),
        _marketService.getStocks(),
      ]);
      crypto = results[0];
      stocks = results[1];
      isShowingCachedData = false;
      cachedAt = null;

      await CacheService.saveCrypto(crypto);
      await CacheService.saveStocks(stocks);
    } catch (e) {
      final cachedCrypto = CacheService.getCachedCrypto();
      final cachedStocks = CacheService.getCachedStocks();

      if (cachedCrypto.isNotEmpty || cachedStocks.isNotEmpty) {
        crypto = cachedCrypto;
        stocks = cachedStocks;
        isShowingCachedData = true;
        cachedAt = CacheService.getLastCachedAt();
        errorMessage = null;
      } else {
        errorMessage = e is MarketServiceException
            ? e.message
            : "Couldn't load market data. Pull down to retry.";
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clears stale data on logout so the next login starts fresh
  /// instead of briefly showing leftover data from the previous session.
  void reset() {
    crypto = [];
    stocks = [];
    isLoading = false;
    errorMessage = null;
    isShowingCachedData = false;
    cachedAt = null;
    notifyListeners();
  }
}