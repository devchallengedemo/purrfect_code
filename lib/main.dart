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
import 'package:flutter/services.dart';

import '/src/game_manager/game_manager.dart';
import 'src/api_module/game_api.dart';
import 'src/app.dart';
import 'src/fallback_app.dart';
import 'src/log/log.dart';

void main() async {
  var validPlatform = await getPlatformState();

  if (validPlatform) {
    var gameManager = GameManager();
    var gameApi = GameApi(gameManager);

    await gameApi.initialize();
    gameApi.buildInterop();

    WidgetsFlutterBinding.ensureInitialized();
    runApp(GameApp(gameManager: gameManager, gameApi: gameApi));
  } else {
    runApp(const Fallback());
  }
}

Future<bool> getPlatformState() async {
  var deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};

  try {
    if (kIsWeb) {
      deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      for (var item in deviceData.entries) {
        if (item.key.contains('browserName')) {
          if (!item.value.toString().toLowerCase().contains('chrome')) {
            return false;
          }
        }
        if (item.key.contains('appVersion')) {
          if (item.value.toString().contains('OS X')) {
            return true;
          } else if (item.value.toString().contains('Windows')) {
            return true;
          } else if (item.value.toString().contains('Linux')) {
            return true;
          }
        }
      }
      return false;
    } else {
      return false;
    }
  } on PlatformException {
    logger.i('Platform exception');
    return false;
  }
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
