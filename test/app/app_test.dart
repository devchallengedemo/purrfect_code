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

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purrfect_code/src/api_module/game_api.dart';
import 'package:purrfect_code/src/game_manager/game_manager.dart';
import 'package:purrfect_code/src/game_view/splash_screen.dart';
import 'package:purrfect_code/src/app.dart';

class _MockGameManager extends Mock implements GameManager {}

void main() {
  group('Game Tests', () {
    late GameManager gameManager;
    late GameApi gameApi;

    setUp(() async {
      gameManager = _MockGameManager();
      gameApi = GameApi(gameManager);
    });

    testWidgets('renders MultiViewWidget', (tester) async {
      await tester.pumpWidget(
        GameApp(
          gameManager: gameManager,
          gameApi: gameApi,
        ),
      );
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });
}
