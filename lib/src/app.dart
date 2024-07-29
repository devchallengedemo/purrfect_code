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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'api_module/device_info.dart';
import 'api_module/game_api.dart';
import 'fallback_app.dart';
import 'game_manager/game_manager.dart';
import 'game_view/multi_view_widget.dart';
import 'game_view/splash_screen.dart';
import 'log/log.dart';

class GameApp extends StatefulWidget {
  GameApp({
    super.key,
    required this.gameManager,
    required this.gameApi,
  });

  final GameManager gameManager;
  final GameApi gameApi;

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  bool initComplete = false;
  bool validPlatform = false;

  @override
  void initState() {
    super.initState();
    initPlatformState().then((valid) {
      setState(() {
        logger.i('setting state');
        initComplete = true;
        validPlatform = valid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initComplete) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.black,
            )),
      );
    } else {
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
  }

  Future<bool> initPlatformState() async {
    logger.i('platform check started');
    var deviceInfo = DeviceInfo();
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfo.deviceInfo());
        for (var item in deviceData.entries) {
          if (item.key.contains('browserName')) {
            var browser =
                deviceInfo.parseUserAgentToBrowserName(item.value.toString());
            if (browser != BrowserName.chrome) return false;
            logger.i('browser is Chrome');
          }
          if (item.key.contains('userAgent')) {
            if (item.value.toString().contains('OS X')) {
              logger.i('browser on OS X');
              return true;
            } else if (item.value.toString().contains('Windows')) {
              logger.i('browser on Windows');
              return true;
            } else if (item.value.toString().contains('Linux')) {
              logger.i('browser on Linux');
              return true;
            }
          }
        }
      }
    } catch (e) {
      logger.e('exception hit $e');
    }

    return false;
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'language': data.language,
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
