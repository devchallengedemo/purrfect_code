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

import 'dart:async';
import 'package:web/web.dart' as web;

class ImportJsLibraryWeb {
  /// Injects the library by its [url]
  static Future<void> import(String url) {
    return _importJSLibraries([url]);
  }

  static web.HTMLScriptElement _createScriptTag(String library) {
    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..type = "text/javascript"
      ..charset = "utf-8"
      ..async = true
      ..defer = true
      ..src = library;
    return script;
  }

  /// Injects a bunch of libraries in the <head> and returns a
  /// Future that resolves when all load.
  static Future<void> _importJSLibraries(List<String> libraries) {
    final List<Future<void>> loading = <Future<void>>[];
    final head = web.document.querySelector('head');

    for (var library in libraries) {
      if (!isImported(library)) {
        final scriptTag = _createScriptTag(library);
        head?.append(scriptTag);
        loading.add(scriptTag.onLoad.first);
      }
    }

    return Future.wait(loading);
  }

  static bool _isLoaded(web.Element head, String url) {
    if (url.startsWith("./")) {
      url = url.replaceFirst("./", "");
    }

    for (var index = 0; index < head.children.length; index++) {
      var element = head.children.item(index);
      if (element.runtimeType != web.HTMLScriptElement) {
        continue;
      } else {
        var scriptElem = element as web.HTMLScriptElement;
        if (scriptElem.src.endsWith(url)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool isImported(String url) {
    final head = web.document.querySelector('head');
    return _isLoaded(head as web.Element, url);
  }
}

class ImportJsLibrary {
  static Future<void> import(String url) {
    return ImportJsLibraryWeb.import(url);
  }

  static bool isImported(String url) {
    return ImportJsLibraryWeb.isImported(url);
  }

  static registerWith(dynamic _) {}
}

Future<void> importJsLibrary(String url) async {
  await ImportJsLibrary.import(url);
}

bool isJsLibraryImported(String url) {
  return ImportJsLibrary.isImported(url);
}
