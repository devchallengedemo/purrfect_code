'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "0b422074d8cd5f1f96e9ec26737683d8",
"version.json": "df754258f324a9b4c6ba3dbf15f5229e",
"index.html": "cdf7edc4cb763bceb9290dd26198128c",
"/": "cdf7edc4cb763bceb9290dd26198128c",
"main.dart.js": "c09aef0deef9a2355d6b9e0a1eeff2da",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "c0888f9c5cc8ed846b6c8261d123e6aa",
"assets/AssetManifest.json": "78eb80f798bce3b46686546234329626",
"assets/NOTICES": "4164533a91435c1513752d325a68c1d0",
"assets/FontManifest.json": "3029d3ea8c4a9132be37b70dd2627f80",
"assets/AssetManifest.bin.json": "9fd9bb26385d9805b53d6d3eb2c9e6e4",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "452431b9919d056415f688d171fb6ae8",
"assets/fonts/ptmono-regular.ttf": "844e8fa6bb3441effec73e976764c535",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/assets/level_base/level01.json": "ba45d69db3f7faa03db5355006f60991",
"assets/assets/level_base/level02.json": "5daf71ce3dde4d1f726bbed026f3b856",
"assets/assets/level_base/level03.json": "62e25a7c6f0fc7610471b980b6560e8d",
"assets/assets/level_base/level04.json": "74f289acc72ffa9273afb730396fecc3",
"assets/assets/level_base/level05.json": "549e442506c31ab059b051084b37cd54",
"assets/assets/level_visual/level03_viz.json": "8fe4ef6a42b7505dc4e27eea8fb4bbe7",
"assets/assets/level_visual/level02_viz.json": "79564743f53fa49717e163efd5052db0",
"assets/assets/level_visual/level04_viz.json": "8abb9580814bd9ca834909c603607bdd",
"assets/assets/level_visual/level05_viz.json": "4192ee4a5ef69db8af4ee72bbd01918b",
"assets/assets/level_visual/level01_viz.json": "5c1a50a2b9aee0ab0e0bcee078d43cf0",
"assets/assets/images/obstacle_plant_2_shadow.png": "ebf18014cf6cd88bf00f93a83ec4172c",
"assets/assets/images/plant_1_shadow.png": "1144c5225b95e0f57c9073dd9749fbf1",
"assets/assets/images/shadow_nw.png": "6748959209d06254aa7b90161a74dc66",
"assets/assets/images/floor_button_up_shadow.png": "9477741a113db581b00c0f0217935090",
"assets/assets/images/bot_spritesheet.png": "65ba34d6c63885817d2eb14718451986",
"assets/assets/images/lowwall_h2s.png": "3e18b6c5909a03e2f7459e1e44d2a4d6",
"assets/assets/images/obstacle_bookcase_1_lefthalf.png": "f31499ca36a6fb2196de45aaa9f88260",
"assets/assets/images/desk_righthalf.png": "3092a42570858a209e6fe59a41791f6c",
"assets/assets/images/lowwall_1s.png": "ed6f934203a77e6e85a0471f065f1640",
"assets/assets/images/floor_0.png": "0ad9ec4cb13ed76b52d10c1e66bd9ce7",
"assets/assets/images/front_wall.png": "d80369f66836afcaf976b021c7c20cfa",
"assets/assets/images/walk_s_spritesheet.png": "7d690d80649514435e353053aa4a7529",
"assets/assets/images/cat_cropped_side.png": "3ea655f08d9c0b608dc2f9a22c2e1398",
"assets/assets/images/trashcan_shadow.png": "ce096d96efa13f1ded0a6db2bc216dad",
"assets/assets/images/box_teleport_shadow_spritesheet.png": "0b39e3511719e3f7d7da3d84bf72df22",
"assets/assets/images/box_teleport_spritesheet.png": "68a173be2795b8bbed6620a6e33dee12",
"assets/assets/images/lowwall_0s.png": "b68f45174f0ae391ce7e4b7a95bb4217",
"assets/assets/images/bot_shadow_spritesheet.png": "1d01e99f53942ed11a022bd3a1b74974",
"assets/assets/images/battery_spritesheet.png": "9bdb47e80c1417445e30614060dd3cdc",
"assets/assets/images/bookcase_1_lefthalf.png": "f31499ca36a6fb2196de45aaa9f88260",
"assets/assets/images/low_wall_shadow.png": "94c2d0c11ac2d60267481222821a00ec",
"assets/assets/images/lowwall_h3s.png": "7edc21d9265618ff3186378c34097d0f",
"assets/assets/images/button_down.png": "703d4d980090abcb46c63baabab839bd",
"assets/assets/images/shadow_ne.png": "955ae3496b43c3f6100bcc5c4feb7e1f",
"assets/assets/images/android_statue_right.png": "20857fbdea1a28a949d07b04884a4400",
"assets/assets/images/floor_03.png": "f0dd635e36dd8f0b7018f923f8685bb5",
"assets/assets/images/lowwall_v3s.png": "79578a3c35e69f5efe3da21021c04a6b",
"assets/assets/images/box_shadow_spritesheet.png": "08987c05fb62f94de4ac77a6db44ff67",
"assets/assets/images/lowwall_2.png": "6cfd96281dd24d4bc31a1674f0cd57aa",
"assets/assets/images/backwall_04.png": "8c96a2e1c0b943d434f9af4025f27247",
"assets/assets/images/obstacle_android_statue_right.png": "9a0921b3b0d987a8165f4e51ce9909f5",
"assets/assets/images/backwall_05.png": "13d682f980641e38747b441f3d192d65",
"assets/assets/images/lowwall_3.png": "49df6b3913750d27bab1b01206c5be34",
"assets/assets/images/monitor_1.png": "ef1097f262525bc48f063b82c917b5b9",
"assets/assets/images/floor_02.png": "085cac3544b9273fa5f9c4354fb286c9",
"assets/assets/images/monitor_3.png": "6a0714bac64f34229b2f599427bc29fe",
"assets/assets/images/obstacle_android_statue_shadow.png": "817462d841dbe9d83ca55a5f666d75d5",
"assets/assets/images/lowwall_1.png": "5e9129a79bf4e5ab4678dd4681185a97",
"assets/assets/images/floor_0_grid_ref.png": "c518b4e0bd6835677fcc1ba1e5468f8e",
"assets/assets/images/trex-run0018.png": "c13c01bbdd47de0c2d0d896bedff6d35",
"assets/assets/images/trex-run0019.png": "9e5a8687e3144d06edeeebb610cdc7c3",
"assets/assets/images/lowwall_0.png": "6f7c8c64efe3247e982568bd2726366c",
"assets/assets/images/shadow_w.png": "0110788a969ba953b6267327e893a82d",
"assets/assets/images/monitor_2.png": "80088bc4596c171b417e04701d4116a5",
"assets/assets/images/floor_01.png": "f0118f439b398c623e3cf2c742c5d950",
"assets/assets/images/floor_05.png": "d36a65107e5e50f066e666ff56ac7e23",
"assets/assets/images/monitor_6.png": "001cb2051815ceb062eafdd6993ca5f7",
"assets/assets/images/obstacle_desk_lefthalf.png": "e0bfed58ce640df647efa01c01ad0748",
"assets/assets/images/shadow_s.png": "d246d2012d8d20a273099b930d11fedf",
"assets/assets/images/lowwall_4.png": "2b2be50a9b170f2c74c914d234606dfe",
"assets/assets/images/backwall_02.png": "d052400a764ce6dd0eef0ef81659987f",
"assets/assets/images/trex-run0009.png": "43de56b7803fe14b3d0098d8186911eb",
"assets/assets/images/trex-run0008.png": "a065d3db281a603dc319369155e5d9a5",
"assets/assets/images/trex-run0020.png": "1a59ae1e74fbecbd1559841f582f03da",
"assets/assets/images/backwall_03.png": "85ad4e4476803ce014261c25544d4610",
"assets/assets/images/lowwall_5.png": "ed9924bea2143107ec65932569dde112",
"assets/assets/images/shadow_e.png": "81e77d46157d4c3c8120bc8435af76b3",
"assets/assets/images/monitor_7.png": "fa7334ed5a3029440c9e6f29334d3d0a",
"assets/assets/images/floor_04.png": "a0a9e93d6baad839456bc419d59440cf",
"assets/assets/images/monitor_5.png": "f70194e21e6be2d58b09c5d3f3819d4b",
"assets/assets/images/backwall_01.png": "5bc396e1495eda4773f15d7d90a12656",
"assets/assets/images/lowwall_6s.png": "588f8339d57acb243047ffbcdf6d800a",
"assets/assets/images/lowwall_6.png": "fb64cb88626709b960e128b3ccf022e8",
"assets/assets/images/button_up_shadow.png": "9477741a113db581b00c0f0217935090",
"assets/assets/images/monitor_4.png": "3d36e1e73958008bc5e6dd8b6fecc752",
"assets/assets/images/lowwall_v2s.png": "671db5b9511931295b7de696f082cd37",
"assets/assets/images/floor_decal_4.png": "959c973064a9b21d42f2488aa7a0da38",
"assets/assets/images/cone_croppedside.png": "0cc9f12c359c0e53aa57f3c4f6f6c4ab",
"assets/assets/images/walls_front.png": "b61dfced7b429e3ebf24a32f18b408b3",
"assets/assets/images/battery_shadow.png": "7e3d7e051204ebb2ad8f2a636c3686af",
"assets/assets/images/bookcase_shadow.png": "4c68185408e32695e28a95b71ed5e022",
"assets/assets/images/cat_1.png": "f8a7c5a18b50ff617396c5a4f05fabd9",
"assets/assets/images/decal_0.png": "008261f3c66101bbf51b2f004378e131",
"assets/assets/images/trex-run0012.png": "a6f8c885fcb174ced57af3aaae1f313a",
"assets/assets/images/trex-run0006.png": "066985b765ed037ee2ef3aa962eb0625",
"assets/assets/images/lowwall_5s.png": "717360237c18fc38d42ee3f4aa63733f",
"assets/assets/images/trex-run0007.png": "b96d9340280c0f51eb865cd9583c4f81",
"assets/assets/images/trex-run0013.png": "c404738fa2128c5cca9a9e0a1537625c",
"assets/assets/images/decal_1.png": "d669ef771af3252974cdbbf89a5d2246",
"assets/assets/images/obstacle_plant_2.png": "8ab56820d1b6b584d6bf992d965fa240",
"assets/assets/images/shadow_sw.png": "6937cc6896cfe8a4fe605f7d64978a28",
"assets/assets/images/lowwall_v1s.png": "ed6f934203a77e6e85a0471f065f1640",
"assets/assets/images/monitor_8.png": "39f711acb72ac7e6b1322a35a0053f3d",
"assets/assets/images/floor_decal_5.png": "9fcf3a8e888d1389912b0be57194ded8",
"assets/assets/images/low_wall.png": "c11ceb441275a8063c205bae98af2423",
"assets/assets/images/obstacle_chair.png": "6719145002ce73b805b4bde709c7655d",
"assets/assets/images/monitor_transition_frame.png": "310c572f0346a48559401e17aca3af10",
"assets/assets/images/cat_2.png": "9ad4222006288125e3e656016078bbeb",
"assets/assets/images/obstacle_bookcase_1_righthalf.png": "ab4ba2ee1e44b8f579faa8b59f8b11a7",
"assets/assets/images/decal_3.png": "f2b4917a63ae58e9f081e1fcf689baeb",
"assets/assets/images/trex-run0005.png": "8f5f1b04ca1c61e8528cb08613d81f83",
"assets/assets/images/trex-run0011.png": "4eb810d240ca9696c02a011376f32004",
"assets/assets/images/trex-run0010.png": "cf59b2dc3baadcfe9d221f2c6a667943",
"assets/assets/images/trex-run0004.png": "2e15bdcb0c78cf6acb43f3b3e1d51be2",
"assets/assets/images/decal_2.png": "386f19785a24e5d8250556d2ca61d1b3",
"assets/assets/images/button_up.png": "eeb657a931b0fc49cbb6084f4dfe8087",
"assets/assets/images/obstacle_chair_shadow.png": "8a9cdd59d77a2aa00ce16b831f0bab6e",
"assets/assets/images/obstacle_android_statue_left.png": "7db72542f18ae8012f0872f61e4f74e3",
"assets/assets/images/cat_3.png": "15e9fc5c6f0ecd92e86634a8d9093201",
"assets/assets/images/obstacle_plant_1.png": "f1877a46347a09cace835aadb1e9c1e2",
"assets/assets/images/floor_decal_2.png": "386f19785a24e5d8250556d2ca61d1b3",
"assets/assets/images/desk_shadow.png": "70f841ce1df577e40308e8df9671d6d1",
"assets/assets/images/lowwall_v3.png": "a6598675d819849ebf06880d33233bbd",
"assets/assets/images/android_statue_left.png": "7db72542f18ae8012f0872f61e4f74e3",
"assets/assets/images/obstacle_bookcase_2_righthalf.png": "436be9b83455ecf08c5d06b6c15e868a",
"assets/assets/images/trex-run0000.png": "85fbb76e50d04f7a9087414aac23ed7c",
"assets/assets/images/trex-run0014.png": "badd66fcfd77de2eb39ac93b51f9f480",
"assets/assets/images/obstacle_bookcase_shadow-v2.png": "a6f9a61fc71e41fba3aef18860a2afcd",
"assets/assets/images/trex-run0015.png": "9165a3e41437e3dd6476e9c04c5418e8",
"assets/assets/images/trex-run0001.png": "3a3efe4d499ae2080b299322c4e7857c",
"assets/assets/images/obstacle_cone_shadow.png": "d88eb95a0cef5b211dd093f9ea5a824a",
"assets/assets/images/lowwall_v2.png": "0cde932ddeeec34492d40fb5c3cb5c1e",
"assets/assets/images/floor_decal_3.png": "f2b4917a63ae58e9f081e1fcf689baeb",
"assets/assets/images/floor_decal_1.png": "d669ef771af3252974cdbbf89a5d2246",
"assets/assets/images/obstacle_cone_croppedside.png": "0cc9f12c359c0e53aa57f3c4f6f6c4ab",
"assets/assets/images/shadow_n.png": "f0f0d15e58fbf3cc85206f9dc75e315f",
"assets/assets/images/cat_4.png": "82980b7cd333dc8aa41b03f770add847",
"assets/assets/images/decal_5.png": "9fcf3a8e888d1389912b0be57194ded8",
"assets/assets/images/lowwall_4s.png": "9256c2818b1fa0dda772621e5dbe22f6",
"assets/assets/images/trex-run0017.png": "01a94868951ad7c2ba61ad0ffcfa4c22",
"assets/assets/images/trex-run0003.png": "6bb4be3cc9c6ff43ef070b3090c3871f",
"assets/assets/images/walls_behind.png": "4f2d10b7cddf414883840abc7a75742c",
"assets/assets/images/trex-run0002.png": "5df436667023560dc11c68f65d9b00e1",
"assets/assets/images/trex-run0016.png": "bfa21a08deba3e45b6a1c4966cf720d6",
"assets/assets/images/floor.png": "428f5972b0e62e17677d4b43ff43606a",
"assets/assets/images/decal_4.png": "959c973064a9b21d42f2488aa7a0da38",
"assets/assets/images/box_spritesheet.png": "f45a241f85e54abd6f9ef422dfa5ec17",
"assets/assets/images/cat_5.png": "d6a7e9c613c43bf19f89b10fc7e89b5a",
"assets/assets/images/lowwall_v1.png": "f2041f64d0e5e4a535778e24302e9145",
"assets/assets/images/shadow_se.png": "2d070a11e8cf0d7e3cba6f0677bb81b1",
"assets/assets/images/floor_decal_0.png": "008261f3c66101bbf51b2f004378e131",
"assets/assets/images/cone_whole.png": "3397a195591433c0db5f6f05a17e4311",
"assets/assets/images/floor_button_up.png": "eeb657a931b0fc49cbb6084f4dfe8087",
"assets/assets/images/lowwall_h1.png": "950931e04805b140c22d0bfce403be02",
"assets/assets/images/android_statue_shadow.png": "ff8709ba46655afe810966ca8cf6ae8b",
"assets/assets/images/cone_shadow.png": "d88eb95a0cef5b211dd093f9ea5a824a",
"assets/assets/images/lowwall_h3.png": "5074a2f5ac850c0750609c89604299a2",
"assets/assets/images/lowwall_3s.png": "0c97c70ed36c33fd7b74136348bcdcd5",
"assets/assets/images/obstacle_cone_whole.png": "3397a195591433c0db5f6f05a17e4311",
"assets/assets/images/lowwall_h2.png": "fe37fd29e4225651ba0f4def15978a66",
"assets/assets/images/obstacle_trashcan_shadow.png": "ce096d96efa13f1ded0a6db2bc216dad",
"assets/assets/images/bookcase_2_righthalf.png": "ce3bb5e4d516a57d5c271712723820e6",
"assets/assets/images/desk_lefthalf.png": "1b4ea3302137b6df51e664a5c9318ed9",
"assets/assets/images/obstacle_bookcase_2_lefthalf.png": "e786bdacffa14c958b6e85e1f47de2b3",
"assets/assets/images/obstacle_desk_shadow.png": "70f841ce1df577e40308e8df9671d6d1",
"assets/assets/images/lowwall_h1s.png": "4faf5c937c60e9e91d6a7ac29fb061f5",
"assets/assets/images/bookcase_2_lefthalf.png": "63d349c6ab3fb6aeeb0ee265b03cb12e",
"assets/assets/images/trashcan_2.png": "ce79e6d6099f022e803c096362fb9f96",
"assets/assets/images/lowwall_2s.png": "3e18b6c5909a03e2f7459e1e44d2a4d6",
"assets/assets/images/plant_1.png": "f1877a46347a09cace835aadb1e9c1e2",
"assets/assets/images/obstacle_trashcan_1.png": "fea3aec27df1006f4b39eba9fe24ead8",
"assets/assets/images/trashcan_3.png": "cc40d703538b7cc0eec8965ecef8a86e",
"assets/assets/images/obstacle_plant_1_shadow.png": "1144c5225b95e0f57c9073dd9749fbf1",
"assets/assets/images/bookcase_1_righthalf.png": "ab4ba2ee1e44b8f579faa8b59f8b11a7",
"assets/assets/images/obstacle_desk_righthalf.png": "aa4f423d970722f68227185da5d2d7f1",
"assets/assets/images/trashcan_1.png": "fea3aec27df1006f4b39eba9fe24ead8",
"assets/assets/images/obstacle_trashcan_3.png": "cc40d703538b7cc0eec8965ecef8a86e",
"assets/assets/images/floor_button_down.png": "703d4d980090abcb46c63baabab839bd",
"assets/assets/images/obstacle_trashcan_2.png": "ce79e6d6099f022e803c096362fb9f96",
"assets/assets/audio/start.mp3": "5a33f56927127892c7547a55e4dced65",
"assets/assets/audio/walk.mp3": "1ad6bdf525cfd6cf7760d155a1c02359",
"assets/assets/audio/catscored.mp3": "0ca637bcde9b85d8c346febdde7c0d7c",
"assets/assets/audio/victory.mp3": "0c57bcd6a3a2b212c2732455933e6395",
"assets/assets/audio/catteleport.mp3": "58465753028a5ffa5260524dcc6f254c",
"assets/assets/audio/battery.mp3": "9e9d8a71324e41fa83de661c58f6f68a",
"assets/assets/api/javascript_api.js": "7c9615f98e92ccf3df8b9322b4477c3e",
"assets/assets/ui_images/level_1_badge.png": "c5fda1281f5e1daa2533e6fa031d26bd",
"assets/assets/ui_images/purrfect_push_tutorial.png": "1ae56532e040aaed4d554ad91608393d",
"assets/assets/ui_images/purrfect_push_level_victory.png": "0dad5fe660a2f0e396c6e3563dbd71f2",
"assets/assets/ui_images/g4d_logo_lockup.png": "ede5e8063521c479c5e8ce1771878ebc",
"assets/assets/ui_images/level_5_badge.png": "a4e4d618e7e509278bba18dccc61dd59",
"assets/assets/ui_images/purrfect_push_splash.png": "9284a6d61e8d77d7f55fb53df38b059d",
"assets/assets/ui_images/level_3_badge.png": "a2879030cc9ae7023e975ef7759afc1e",
"assets/assets/ui_images/purrfect_push_failure.png": "14986b331f38d4aa7717baf1ebd162d3",
"assets/assets/ui_images/level_4_badge.png": "762c003363b2c347fc7e62742c27c538",
"assets/assets/ui_images/level_2_badge.png": "c3ad5e5381c378b9adb50951e850fb31",
"assets/assets/ui_images/purrfect_push_game_victory.png": "c27c16f8945b85030c151781a4f72173",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
