import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logixa_edl_ai/app/modules/home/controllers/home_controller.dart';
import 'package:logixa_edl_ai/app/widgets/core_page.dart';
import 'screens/home_main_screen.dart';
import 'sections/home_sidebar.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CorePage(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: const [
            HomeSidebar(),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: HomeMainScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
