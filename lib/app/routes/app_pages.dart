import 'package:get/get.dart';

import '../modules/chat_page/bindings/chat_page_binding.dart';
import '../modules/chat_page/views/chat_page_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/work_space/bindings/work_space_binding.dart';
import '../modules/work_space/views/work_space_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.workSpace,
      page: () => const WorkSpaceView(),
      binding: WorkSpaceBinding(),
    ),
    GetPage(
      name: _Paths.chatPage,
      page: () => const ChatPageView(),
      binding: ChatPageBinding(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
