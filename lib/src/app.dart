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
import '/src/game_view/multi_view_widget.dart';
import 'api_module/game_api.dart';
import 'game_view/splash_screen.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key, required this.gameManager, required this.gameApi});

  final GameManager gameManager;
  final GameApi gameApi;

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          'Z2FtZQ==': (context) =>
              MultiViewWidget(gameManager: widget.gameManager),
        });
  }
}
