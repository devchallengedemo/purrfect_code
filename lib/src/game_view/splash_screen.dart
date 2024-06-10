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

import 'dart:convert';

import 'package:flutter/material.dart';

import '../log/log.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            SizedBox(
              width: 600,
              height: 40,
              child: TextField(
                controller: textController,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Enter Password',
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height:40),
            ElevatedButton(
            onPressed: () {
                  //Navigator.pushNamed(context, 'game');
                  _validatePassword(textController.text, context);
              },
              child: const Text('Launch screen'),
            ),
          ],
        ),
      ),
    );
  }

  void _validatePassword(String text, BuildContext context)
  {
    final str = utf8.decode(base64.decode('OXFlaWJFS3JzVlZMMmppeWFpWWI='));
    logger.i('decoded string= $str, password= $text');
    if(text == str) {
      Navigator.pushNamed(context, 'Z2FtZQ==');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Password'),
            actions: <Widget>[
              TextButton(
                child: const Text('Retry'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

