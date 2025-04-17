import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:petrel/petrel.dart';

class InAppWebViewEngine extends WebViewEngine {
  final InAppWebViewController controller;

  InAppWebViewEngine({required this.controller});

  @override
  void runJavaScript(String script) {
    logger.d('runJavaScript: $script');
    controller.evaluateJavascript(source: script);
  }
}
