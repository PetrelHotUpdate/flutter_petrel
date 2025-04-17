import 'package:petrel/petrel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebViewEngine extends WebViewEngine {
  final WebViewController controller;

  AppWebViewEngine({required this.controller});

  @override
  void runJavaScript(String script) {
    logger.i('runJavaScript: $script');
    controller.runJavaScript(script);
  }
}
