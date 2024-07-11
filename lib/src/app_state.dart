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

AppState get appState => AppState.instance;

enum AppCurrentState { nil, loading, loaded, running }

class AppState {
  AppState._() : super();
  static final instance = AppState._();
  final lastLevel = 5;
  double volume = 0.33;

  int _level = 1;
  AppCurrentState _state = AppCurrentState.nil;
  AppCurrentState get state => _state;
  void setState(AppCurrentState state) {
    _state = state;
  }

  int getLevel() => _level;
  int setLevel(int value) => _level = value;
}
