import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../vision_detector_views/barcode_scanner_view.dart';
import '../widgets/ConnectButton.dart';
import '../widgets/lingJianList.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PtsLingJian extends StatefulWidget {
  const PtsLingJian({Key? key}) : super(key: key);

  @override
  _PtsLingJianState createState() => _PtsLingJianState();
}

class _PtsLingJianState extends State<PtsLingJian> {
  late dynamic box;
  late Map<String, dynamic> json_barcode = {};
  @override
  void initState() {
    initHive();
    super.initState();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox('lingJian');
    viewPageBarcode = BarcodeScannerView(onScanAfter: (barcode) async {
      //var box = await Hive.openBox('lingJian');
      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
      var item = {
        'id': barcode,
        'barcode': barcode,
        'scan_dt': formattedDate,
        'ack': 'enter',
        'is_send': 0,
      };
      int correctIndex = box.values.toList().indexWhere((element) => element['id'] == item['id']);
      if (correctIndex == -1) {
        await box.put(barcode, item);
        setState(() {
          print('更新資料');
        });
      } else {
        print('資料已經存在了');
      }

      //print('item: $item');
      //setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //box = Hive.openBox('lingJian');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('PTS-零件上機/下機'),
      ),
      child: Expanded(
          child: Scaffold(
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(
            height: 90,
          ),
          Center(
            child: Builder(
              builder: (context) {
                return ConnectButton();
              },
            ),
          ),
          Stack(
            children: <Widget>[
              Transform.translate(
                offset: Offset(0, -20),
                child: LingJianList(),
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white, // 設置底色
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Colors.blue, width: 1.0), // 設置邊框
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0), // 設置圓角
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.plus_one), // 相機圖標
                                SizedBox(width: 8), // 圖標和文本之間的間距
                              ],
                            ),
                            onPressed: () async {
                              var box = await Hive.openBox('lingJian');
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
                              print('item: $item');
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.blue, width: 1.0), // 設置邊框
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0), // 設置圓角
                            ),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => viewPageBarcode),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt), // 相機圖標
                              SizedBox(width: 8), // 圖標和文本之間的間距
                              Text('掃描'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ])),
      )),
    );
  }
}
