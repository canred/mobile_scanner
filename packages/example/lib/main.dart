// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

bool qrcode_isBusy = false;

bool mqttIsOnline = false;
String deviceName = '';
late Widget viewPageQrcode;
late Widget viewPageBarcode;
late Widget cpConnectButton;

// Function connectServer;
// Widget viewPageQrcode;
// Function onJsonDecoded;

void main() async {
  await dotenv.load(fileName: 'assets/.env');
  await Hive.initFlutter();
  var box = await Hive.openBox('lingJian');
  if (box.values.length == 0) {
    var uuid = Uuid();
    var now = DateTime.now();
    var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
    var item = {
      'id': uuid.v4(),
      'barcode': uuid.v4(),
      'scan_dt': formattedDate,
      'ack': 'enter',
      'is_send': 0,
    };
    await box.put(item['id'], item);
  }

  var box_setting = await Hive.openBox('vis_scanner_setting');
  if (box_setting.values.length == 0) {
    var item_setting = {
      'mqtt_server': '',
      'mqtt_topic': '',
      'pc_name': '',
    };
    await box_setting.put('mqtt_setting', item_setting);
  }
  // var box = await Hive.openBox('lingJian');

  return runApp(CupertinoStoreApp());
}
