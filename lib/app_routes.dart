import 'package:get/get.dart';
import 'package:one_chat/pages/about_page.dart';
import 'package:one_chat/pages/chat_edit_page.dart';
import 'package:one_chat/pages/chat_massage_page.dart';
import 'package:one_chat/pages/home_page.dart';
import 'package:one_chat/pages/image_viewer_page.dart';
import 'package:one_chat/pages/prompt_list_page.dart';
import 'package:one_chat/pages/server_settings_page.dart';

final appRoutes = [
  GetPage(
      name: '/',
      page: () {
        return HomePage();
      }),
  GetPage(name: '/settings', page: () => ServerSettingsPage()),
  GetPage(name: '/editchat', page: () => ChatEditPage()),
  GetPage(name: '/chat', page: () => ChatMessagePage()),
  GetPage(name: '/about', page: () => AboutPage()),
  GetPage(name: '/prompts', page: () => PromptListPage()),
  GetPage(
    name: "/image/view",
    page: () => ImageViewerPage(),
    transition: Transition.zoom,
    // transitionDuration: Duration(milliseconds: 1000),
  )
];
