import 'package:pet/core/utils/app_logger.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Captures a widget painted inside a [RepaintBoundary] as an image
/// and shares it via the platform share sheet.
///
/// Usage:
/// ```dart
/// final key = GlobalKey();
/// RepaintBoundary(key: key, child: MyWidget());
/// await GoalSharingService.instance.shareWidget(key, 'My Goal Progress');
/// ```
class GoalSharingService {
  GoalSharingService._();
  static final GoalSharingService instance = GoalSharingService._();

  /// Capture the widget in [boundaryKey] as a PNG and share it.
  Future<void> shareWidget(GlobalKey boundaryKey, String subject) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pet_goal_progress.png');
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: subject,
          text: 'Check out my savings progress on P.E.T! 🐾',
        ),
      );
    } catch (e) {
      AppLogger.debug('[GoalSharing] Error: $e');
    }
  }
}
