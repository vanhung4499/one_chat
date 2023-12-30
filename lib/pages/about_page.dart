import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:one_chat/controllers/main_controller.dart';
import 'package:one_chat/controllers/settings_controller.dart';
import 'package:one_chat/controllers/tracker_controller.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  MainController mainController = Get.find();
  SettingsController settingsController = Get.find();
  TrackerController tracker = Get.find();

  @override
  Widget build(BuildContext context) {
    tracker
        .trackEvent("Page-About", {"uuid": settingsController.settings.uuid});

    return Scaffold(
      appBar: AppBar(
        title: Text("About".tr),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  "One Chat (v${settingsController.packageInfo.version})",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownWidget(
                        data: "One Chat Intro".tr,
                        shrinkWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
