import 'package:flutter/foundation.dart';
import '../services/watchlist_service.dart';

class WatchlistProvider extends ChangeNotifier {
  Set<String> watchedSymbols = {};

  WatchlistProvider() {
    watchedSymbols = WatchlistService.getSymbols().toSet();
  }

  bool isWatched(String symbol) => watchedSymbols.contains(symbol);

  Future<void> toggle(String symbol) async {
    if (watchedSymbols.contains(symbol)) {
      watchedSymbols.remove(symbol);
      await WatchlistService.removeSymbol(symbol);
    } else {
      watchedSymbols.add(symbol);
      await WatchlistService.addSymbol(symbol);
    }
    notifyListeners();
  }
}