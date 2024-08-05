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

import 'dart:math';

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var heightOffset = height * 0.6;
    var maxBoxHeight = 280.0;
    var calculatedHeight =
        min(maxBoxHeight, MediaQuery.of(context).size.height * 0.3);
    var calculatedFontSize = 24.0 * (calculatedHeight / maxBoxHeight);
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ui_images/purrfect_code_splash.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: heightOffset),
            const SizedBox(height: 40),
            Container(
              width: 500,
              height: calculatedHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
                    child: Text(
                      '''Purrfect Code is a multi-level coding challenge where developers program a robot to efficiently move boxes with cats to safety, emphasizing code efficiency.
''',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: calculatedFontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  OutlinedButton(
                    style: ButtonStyle(
                      side: WidgetStateProperty.all(const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                          style: BorderStyle.solid)),
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.transparent;
                        }
                        return Colors.lightBlue;
                      }),
                      overlayColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.lightBlue;
                        }
                        return Colors.lightBlue;
                      }),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'game');
                    },
                    child: const Text(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                        ),
                        'Play Purrfect Code'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
