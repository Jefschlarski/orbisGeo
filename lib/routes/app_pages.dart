import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/views/home.dart';

import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomePage(
        onOpenCamera: () {},
        onViewHistory: () {},
      ), // binding: InitialBinding
    )
  ];
}
