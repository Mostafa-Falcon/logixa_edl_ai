import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:logixa_edl_ai/app/widgets/core_page.dart';

import '../controllers/chat_page_controller.dart';

class ChatPageView extends GetView<ChatPageController> {
  const ChatPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return CorePage(
      body: const Center(
        child: Text('ChatPageView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
