import 'dart:io' show Platform;

/// Native platform checks — used on Android, iOS, Windows, Linux, macOS.
bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;
bool get isWindows => Platform.isWindows;
bool get isLinux => Platform.isLinux;
bool get isMacOS => Platform.isMacOS;
