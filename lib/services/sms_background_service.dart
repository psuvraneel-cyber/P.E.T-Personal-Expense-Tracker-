import 'package:pet/core/utils/app_logger.dart';
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:pet/services/sms_service.dart';
import 'package:pet/services/reconciliation_service.dart';

/// Background task name for periodic SMS inbox scanning.
const String kSmsInboxScanTask = 'com.pet.tracker.smsInboxScan';

/// Background task name for periodic reconciliation sweep.
const String kReconciliationSweepTask = 'com.pet.tracker.reconciliationSweep';

/// Top-level callback dispatcher for WorkManager.
/// This MUST be a top-level function (not a class method).
///
/// Uses SmsService.scanInbox() which internally uses the native ContentResolver
/// to read SMS from the system content provider — works regardless of which
/// app is set as the default SMS handler.
///
/// Performs incremental scanning: only looks back as far as needed based
/// on the last processed timestamp stored in SharedPreferences.
@pragma('vm:entry-point')
void smsCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppLogger.debug('[PET-BG] Executing background task: $taskName');

    if (taskName == kSmsInboxScanTask) {
      try {
        // Use a short lookback (2 days) since we run every 15 minutes.
        // The hash-based dedup and lastProcessedTimestamp watermark
        // in SmsService prevent duplicates regardless.
        final smsService = SmsService();
        final count = await smsService.scanInbox(lookbackDays: 2);
        AppLogger.debug(
          '[PET-BG] Background scan found $count new transactions',
        );
      } catch (e) {
        AppLogger.debug('[PET-BG] Background scan error: $e');
      }
    } else if (taskName == kReconciliationSweepTask) {
      try {
        final reconciliationService = ReconciliationService();
        final count = await reconciliationService.reconcile();
        AppLogger.debug(
          '[PET-BG] Background reconciliation found $count new transactions',
        );
      } catch (e) {
        AppLogger.debug('[PET-BG] Background reconciliation error: $e');
      }
    }

    return Future.value(true);
  });
}

/// Initialize WorkManager for periodic background SMS scanning.
///
/// Call this once during app startup (after permissions are granted).
Future<void> initSmsBackgroundService() async {
  if (!Platform.isAndroid) return;

  await Workmanager().initialize(smsCallbackDispatcher);

  // Register a periodic task that runs every 15 minutes (minimum interval).
  // WorkManager handles battery optimization and doze mode automatically.
  await Workmanager().registerPeriodicTask(
    kSmsInboxScanTask,
    kSmsInboxScanTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: true,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );

  // Register a periodic reconciliation sweep that runs every 6 hours.
  // This provides a safety net for transactions missed by the real-time
  // listener and the 15-minute scan task. Uses requiresBatteryNotLow
  // and requiresDeviceIdle to minimize battery impact.
  await Workmanager().registerPeriodicTask(
    kReconciliationSweepTask,
    kReconciliationSweepTask,
    frequency: const Duration(hours: 6),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: true,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
  );

  AppLogger.debug(
    '[PET-BG] Background SMS scan + reconciliation services initialized',
  );
}

/// Cancel background SMS scanning and reconciliation.
Future<void> cancelSmsBackgroundService() async {
  if (!Platform.isAndroid) return;
  await Workmanager().cancelByUniqueName(kSmsInboxScanTask);
  await Workmanager().cancelByUniqueName(kReconciliationSweepTask);
  AppLogger.debug(
    '[PET-BG] Background SMS scan + reconciliation services cancelled',
  );
}
