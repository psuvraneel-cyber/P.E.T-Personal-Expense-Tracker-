import 'package:pet/data/models/enums.dart';
import 'package:pet/data/models/transaction.dart';

class AnomalyDetectionService {
  AnomalyDetectionService._();

  static Map<String, double> detectCategorySpikes(
    List<TransactionRecord> transactions,
    Map<String, double> baseline,
  ) {
    final current = <String, double>{};

    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      current[t.categoryId] = (current[t.categoryId] ?? 0) + t.amount;
    }

    final spikes = <String, double>{};
    for (final entry in current.entries) {
      final base = baseline[entry.key] ?? 0;
      if (base <= 0) continue;
      final ratio = entry.value / base;
      if (ratio >= 1.8) {
        spikes[entry.key] = ratio;
      }
    }
    return spikes;
  }
}
