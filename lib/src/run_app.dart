import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_pages.dart';

runPetrelApp({
  required String initialRoute,
  required List<GetPage> getPages,
  String? title,
}) {
  AppPages.registerRoute(getPages);
  runApp(
    GetMaterialApp(
      title: title ?? "Application",
      initialRoute: initialRoute,
      getPages: getPages,
    ),
  );
}
