/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/src/game_manager/game_manager.dart';
import '/src/game_view/multi_view_widget.dart';
import 'api_module/game_api.dart';
import 'fallback_app.dart';
import 'game_view/splash_screen.dart';
import 'log/log.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key, required this.gameManager, required this.gameApi});

  final GameManager gameManager;
  final GameApi gameApi;

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  bool platformCheckComplete = false;
  bool validPlatform = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    if (!platformCheckComplete) {
      return Container();
    }

    if (validPlatform) {
      return MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            'Z2FtZQ==': (context) =>
                MultiViewWidget(gameManager: widget.gameManager),
          });
    } else {
      return Fallback();
    }
  }

  Future<void> initPlatformState() async {
    var deviceInfoPlugin = DeviceInfoPlugin();
    var deviceData = <String, dynamic>{};
    var valid = false;

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
        for (var item in deviceData.entries) {
          if (item.key.contains('browserName')) {
            if (!item.value.toString().toLowerCase().contains('chrome')) {
              logger.e('browser not chrome');
            }
          }
          if (item.key.contains('appVersion')) {
            if (item.value.toString().contains('OS X')) {
              logger.i('browser on OS X');
              valid = true;
            } else if (item.value.toString().contains('Windows')) {
              logger.i('browser on Windows');
              valid = true;
            } else if (item.value.toString().contains('Linux')) {
              logger.i('browser on Linux');
              valid = true;
            }
          }
        }
      }
    } catch (e) {
      logger.e('exception hit $e');
    }

    setState(() {
      platformCheckComplete = true;
      validPlatform = valid;
    });
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }
}
