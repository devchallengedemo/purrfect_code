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

import 'package:flutter/material.dart';
import '/src/game_manager/game_manager.dart';
import 'src/api_module/game_api.dart';
import 'src/app.dart';
import 'src/fallback_app.dart';

void main() async {
  await getPlatformState().then((validPlatform) async {
    if (validPlatform) {
      var gameManager = GameManager();
      var gameApi = GameApi(gameManager);

      await gameApi.initialize();
      gameApi.buildInterop();

      WidgetsFlutterBinding.ensureInitialized();
      runApp(GameApp(gameManager: gameManager, gameApi: gameApi));
    } else {
      runApp(Fallback());
    }
  });
}

Future<bool> getPlatformState() async {
  //var deviceData = <String, dynamic>{};
  return true;
/*
  try {
    if (kIsWeb) {
      deviceData = _readWebBrowserInfo(await webBrowserInfo());
      for (var item in deviceData.entries) {
        if (item.key.contains('browserName')) {
          if (!item.value.toString().toLowerCase().contains('chrome')) {
            logger.e('browser not chrome');
            return false;
          }
        }
        if (item.key.contains('appVersion')) {
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
      logger.i('browser on not supported');
      return false;
    } else {
      logger.i('not running on web');
      return false;
    }
  } on PlatformException {
    logger.i('Platform exception');
    return false;
  }
  */
}
/*
Map<String, dynamic> _readWebBrowserInfo(BrowserData data) {
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
*/
