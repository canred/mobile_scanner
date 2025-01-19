import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/ConnectButton.dart';
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
  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox('lingJian');
  }

  @override
  Widget build(BuildContext context) {
    box = Hive.openBox('lingJian');

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
          ElevatedButton(
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
              child: Text('產生假資料')),
          Transform.translate(
            offset: Offset(0, -70), // 向上移動 100 單位
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200, // 設置高度
              child: Container(
                decoration: BoxDecoration(
                    //border: Border.all(color: Colors.blue, width: 2.0), // 設置邊框
                    ),
                child: ValueListenableBuilder(
                  valueListenable: Hive.box('lingJian').listenable(),
                  builder: (context, Box box, _) {
                    List<Map<dynamic, dynamic>> sortedItems = [];
                    for (var i = 0; i < box.length; i++) {
                      sortedItems.add(box.getAt(i));
                    }
                    sortedItems.sort((a, b) => a['scan_dt'].compareTo(b['scan_dt']));
                    return ListView.builder(
                      //shrinkWrap: true,
                      itemCount: sortedItems.length,
                      itemBuilder: (context, index) {
                        var item = sortedItems[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1.0), // 設置邊框
                            borderRadius: BorderRadius.circular(8.0), // 設置圓角
                          ),
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // 設置外邊距
                          child: ListTile(
                            title: Text(item['scan_dt']),
                            subtitle: Text(item['barcode']),
                            trailing: Text(item['ack']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ])),
      )),
    );
  }
}
