import 'dart:async';
import 'package:web/web.dart' as html show window;

class DeviceInfo {
  Future<WebBrowserInfo> deviceInfo() {
    var nav = html.window.navigator;
    return Future<WebBrowserInfo>.value(
      WebBrowserInfo.fromMap(
        {
          'appCodeName': nav.appCodeName,
          'appName': nav.appName,
          'appVersion': nav.appVersion,
          'language': nav.language,
          'languages': nav.languages,
          'platform': nav.platform,
          'product': nav.product,
          'productSub': nav.productSub,
          'userAgent': nav.userAgent,
          'vendor': nav.vendor,
          'vendorSub': nav.vendorSub,
          'hardwareConcurrency': nav.hardwareConcurrency,
          'maxTouchPoints': nav.maxTouchPoints,
        },
      ),
    );
  }
}

enum BrowserName {
  firefox,
  samsungInternet,
  opera,
  msie,
  edge,
  chrome,
  safari,
  unknown,
}

class WebBrowserInfo {
  WebBrowserInfo({
    required this.appCodeName,
    required this.appName,
    required this.appVersion,
    required this.language,
    required this.platform,
    required this.product,
    required this.productSub,
    required this.userAgent,
    required this.vendor,
    required this.vendorSub,
    required this.maxTouchPoints,
    required this.hardwareConcurrency,
  });

  BrowserName get browserName {
    return _parseUserAgentToBrowserName();
  }

  final String? appCodeName;
  final String? appName;
  final String? appVersion;
  final String? language;
  final String? platform;
  final String? product;
  final String? productSub;
  final String? userAgent;
  final String? vendor;
  final String? vendorSub;
  final int? hardwareConcurrency;
  final int? maxTouchPoints;

  static WebBrowserInfo fromMap(Map<String, dynamic> map) {
    return WebBrowserInfo(
      appCodeName: map['appCodeName'] as String,
      appName: map['appName'] as String,
      appVersion: map['appVersion'] as String,
      language: map['language'] as String,
      platform: map['platform'] as String,
      product: map['product'] as String,
      productSub: map['productSub'] as String,
      userAgent: map['userAgent'] as String,
      vendor: map['vendor'] as String,
      vendorSub: map['vendorSub'] as String,
      hardwareConcurrency: map['hardwareConcurrency'] as int,
      maxTouchPoints: map['maxTouchPoints'] as int,
    );
  }

  BrowserName _parseUserAgentToBrowserName() {
    final userAgent = this.userAgent;
    if (userAgent == null) {
      return BrowserName.unknown;
    } else if (userAgent.contains('Firefox')) {
      return BrowserName.firefox;
    } else if (userAgent.contains('SamsungBrowser')) {
      return BrowserName.samsungInternet;
    } else if (userAgent.contains('Opera') || userAgent.contains('OPR')) {
      return BrowserName.opera;
    } else if (userAgent.contains('Trident')) {
      return BrowserName.msie;
    } else if (userAgent.contains('Edg')) {
      return BrowserName.edge;
    } else if (userAgent.contains('Chrome')) {
      return BrowserName.chrome;
    } else if (userAgent.contains('Safari')) {
      return BrowserName.safari;
    } else {
      return BrowserName.unknown;
    }
  }
}
