
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_petrel/src/web_view_engine.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:petrel/petrel.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: implementation_imports

class DynamicPage extends GetView<DynamicPageController> {
  const DynamicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final url = controller.loadUrl.value;
        final loadingWidget = controller.loadWidget ?? const SizedBox.shrink();
        if (url.isEmpty) return loadingWidget;
        return _buildWebView(url);
      }),
    );
  }

  // Widget _buildInAppWebView(String url) {
  //   return InAppWebView(
  //     initialUrlRequest: URLRequest(url: Uri.parse(url)),
  //     onWebViewCreated: (webViewController) {
  //       final webViewEngine = InAppWebViewEngine(controller: webViewController);
  //       logger.d('initEngineWithMessageEngine');
  //       nativeChannelEngine.initEngineWithMessageEngine(
  //         messageEngine: MessageEngine(webViewEngine),
  //       );
  //       logger.d('addJavaScriptHandler: $webCallNativeName');
  //       webViewController.addJavaScriptHandler(
  //         handlerName: webCallNativeName,
  //         callback: (data) {
  //           nativeChannelEngine.onReceiveMessageHandler(data.first);
  //         },
  //       );
  //       logger.d('addJavaScriptHandler: $nativeCallWebHandlerName');
  //       webViewController.addJavaScriptHandler(
  //         handlerName: nativeCallWebHandlerName,
  //         callback: (data) {
  //           nativeChannelEngine.onReceiveCallBackMessageHandler(data.first);
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildWebView(String url) {
    return WebViewWidget(controller: controller.webViewController);
  }
}

class DynamicPageController extends GetxController {
  late InAppLocalhostServer _localhostServer;
  late Widget? loadWidget;
  var loadUrl = ''.obs;
  late String routeName;

  late WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();
    routeName = Get.arguments['routeName'];
    final port = JSON(Get.arguments)['port'].int ?? 8080;
    final documentRoot = Get.arguments['documentRoot'] ?? './';
    final directoryIndex =
        JSON(Get.arguments)['directoryIndex'].string ?? 'index.html';
    final shared = JSON(Get.arguments)['shared'].bool ?? false;
    loadWidget = Get.arguments['loadWidget'];

    _localhostServer = InAppLocalhostServer(
      port: port,
      documentRoot: documentRoot,
      directoryIndex: directoryIndex,
      shared: shared,
    );
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
        ),
      )
      ..addJavaScriptChannel(webCallNativeName, onMessageReceived: (e) async {
        nativeChannelEngine.onReceiveMessageHandler(e.message);
      })
      ..addJavaScriptChannel(nativeCallWebHandlerName, onMessageReceived: (e) {
        nativeChannelEngine.onReceiveCallBackMessageHandler(e.message);
      })
      ..setOnConsoleMessage((e) {
        logger.d('onConsoleMessage: ${e.message}');
      });

    nativeChannelEngine.initEngineWithMessageEngine(
      messageEngine:
          MessageEngine(AppWebViewEngine(controller: webViewController)),
    );

    _localhostServer.start().then((value) {
      loadUrl.value = 'http://localhost:$port/$directoryIndex';
      webViewController.loadRequest(Uri.parse(loadUrl.value));
    });
  }

  @override
  void onClose() {
    _localhostServer.close();
    super.onClose();
  }
}

class DynamicPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DynamicPageController>(() => DynamicPageController());
  }
}
