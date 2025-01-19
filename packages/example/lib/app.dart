import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

import 'pages/ptsLingJian.dart';
import 'vision_detector_views/qrcode_scanner_view.dart';
import 'vision_detector_views/barcode_scanner_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bot_toast/bot_toast.dart';

late MqttBrowserClient clientBrowser;
late MqttServerClient clientServer;
late bool mqtt_is_on_line = false;
late Map<String, dynamic> json_qrcode = {};
String deviceInfo = 'Loading...';
String deviceName = '';

class CupertinoStoreApp extends StatefulWidget {
  @override
  _CupertinoStoreAppState createState() => _CupertinoStoreAppState();
}

class _CupertinoStoreAppState extends State<CupertinoStoreApp> {
  @override
  Widget build(BuildContext context) {
    dotenv.load(fileName: 'assets/.env');
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      builder: (context, child) {
        child = BotToastInit()(context, child); // 初始化 BotToast
        return child;
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [BotToastNavigatorObserver()],
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatefulWidget {
  const CupertinoStoreHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CupertinoStoreHomePageState createState() => _CupertinoStoreHomePageState();
}

class _CupertinoStoreHomePageState extends State<CupertinoStoreHomePage> {
  final Widget _viewPage_bc = BarcodeScannerView();
  final Widget _PtsLingJian = PtsLingJian();
  late Widget _viewPage_qrcode;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('VIS Scanner'),
        leading: Icon(CupertinoIcons.bars), // 加上系統設定的 ICON
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 插入一個空白的空間
          SizedBox(height: 80),
          SizedBox(
            height: 120, // 設置高度
            width: MediaQuery.of(context).size.width * 0.95, // 設置寬度
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/connect.png'), // 設置背景圖片
                  fit: BoxFit.fitWidth,
                ),
                borderRadius: BorderRadius.circular(8.0), // 設置邊框圓角
              ),
              child: ElevatedButton(
                onPressed: () => {
                  // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  //   content: Text("連接失敗，請檢查網路連線。1111"),
                  // ))
                  BotToast.showText(
                    text: '連接失敗，請檢查網路連線。2222',
                    duration: Duration(seconds: 3),
                    align: Alignment.bottomCenter,
                    contentColor: Colors.red,
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                  )
                },
                onLongPress: () {
                  // 長按事件的處理邏輯
                  this._viewPage_qrcode = QrcodeScannerView(onJsonDecoded: (json) {
                    json_qrcode = json;
                    deviceName = json_qrcode['topic'];
                    connect_Server(json_qrcode['mqtt'], json_qrcode['topic']);
                  });

                  Navigator.push(context, MaterialPageRoute(builder: (context) => this._viewPage_qrcode));
                },
                style: ElevatedButton.styleFrom(
                  //,
                  backgroundColor: mqtt_is_on_line ? const Color.fromARGB(255, 246, 247, 246).withOpacity(0.7) : const Color.fromARGB(255, 247, 8, 8).withOpacity(0.5),
                  shadowColor: Colors.transparent, // 設置陰影顏色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // 設置按鈕圓角
                  ),
                ),
                child: Column(children: [
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft, // 將文字靠左對齊
                    child: Text(
                      mqtt_is_on_line ? '裝置連線中' : '未連接裝置',
                      style: TextStyle(fontSize: 24, color: mqtt_is_on_line ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft, // 將文字靠左對齊
                    child: Text(
                      mqtt_is_on_line ? deviceName : "---",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: const Color.fromARGB(255, 17, 17, 204)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft, // 將文字靠左對齊
                    child: Text(
                      '連接新電腦，請長按。',
                      style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                  )
                ]), // 按鈕文字
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero, // 移除內邊距

                      onPressed: () {
                        // 按鈕點擊事件處理邏輯
                        Navigator.push(context, MaterialPageRoute(builder: (context) => this._PtsLingJian));
                      },
                      child: SizedBox(
                        height: 200, // 設置高度
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0), // 設置圓角
                                child: Image.asset(
                                  'assets/images/btn_01.jpg', // 替換為你的按鈕底圖路徑
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              color: CupertinoColors.white.withOpacity(0.7),
                              width: double.infinity,
                              padding: EdgeInsets.all(8.0), // 添加一些內邊距
                              child: Text(
                                'PTS\n零件上機/下機',
                                style: TextStyle(color: CupertinoColors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0), // 設置圓角
                            child: Image.asset(
                              'assets/images/btn_02.jpg', // 替換為你的按鈕底圖路徑
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: CupertinoColors.white.withOpacity(0.7),
                          width: double.infinity,
                          padding: EdgeInsets.all(8.0), // 添加一些內邊距
                          child: Text(
                            'Excel\n掃描到Excel',
                            style: TextStyle(color: CupertinoColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0), // 設置圓角
                            child: Image.asset(
                              'assets/images/btn_03.jpg', // 替換為你的按鈕底圖路徑
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: CupertinoColors.white.withOpacity(0.7),
                          width: double.infinity,
                          padding: EdgeInsets.all(8.0), // 添加一些內邊距
                          child: Text(
                            'PTS\n出貨QC檢查',
                            style: TextStyle(color: CupertinoColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0), // 設置圓角
                            child: Image.asset(
                              'assets/images/btn_busy.jpg', // 替換為你的按鈕底圖路徑
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: CupertinoColors.white.withOpacity(0.7),
                          width: double.infinity,
                          padding: EdgeInsets.all(8.0), // 添加一些內邊距
                          child: Text(
                            '\n施工中',
                            style: TextStyle(color: CupertinoColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0), // 設置圓角
                            child: Image.asset(
                              'assets/images/btn_busy.jpg', // 替換為你的按鈕底圖路徑
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: CupertinoColors.white.withOpacity(0.7),
                          width: double.infinity,
                          padding: EdgeInsets.all(8.0), // 添加一些內邊距
                          child: Text(
                            '\n施工中',
                            style: TextStyle(color: CupertinoColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0), // 設置圓角
                            child: Image.asset(
                              'assets/images/btn_busy.jpg', // 替換為你的按鈕底圖路徑
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: CupertinoColors.white.withOpacity(0.7),
                          width: double.infinity,
                          padding: EdgeInsets.all(8.0), // 添加一些內邊距
                          child: Text(
                            '\n施工中',
                            style: TextStyle(color: CupertinoColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '© 2025 世界先進. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> connect_Server(String mqtt_ip, String topic) async {
    print('canred-mqtt-01');
    setupMqttClient_Server(mqtt_ip, topic);
    print('canred-mqtt-02');
    try {
      await clientServer.connect();
      print('canred-mqtt-03');
      setState(() {
        mqtt_is_on_line = true;
      });
    } on NoConnectionException catch (e) {
      print('NoConnectionException:$e');
      clientServer.disconnect();
    } on SocketException catch (e) {
      //print('SocketException:$e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("連接失敗，請檢查網路連線。1111"),
      ));
      BotToast.showText(
        text: '連接失敗，請檢查網路連線。2222',
        duration: Duration(seconds: 3),
        align: Alignment.bottomCenter,
        contentColor: Colors.red,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      );
      //clientServer.disconnect();
    } on Exception catch (e) {
      print('Exception:$e');
      clientServer.disconnect();
    } catch (e) {
      print('Error:$e');
      clientServer.disconnect();
    }
  }

  void setupMqttClient_Server(String qrCode_mqtt_serverip, String topic) {
    if (qrCode_mqtt_serverip != '' && topic != '') {
      dotenv.env['MQTT_SERVER_URL'] = "ws://" + qrCode_mqtt_serverip;
    }
    clientServer = MqttServerClient(dotenv.env['MQTT_SERVER_URL']!, 'flutter_client');
    clientServer.port = int.parse(dotenv.env['MQTT_PORT']!);
    clientServer.secure = false;
    clientServer.useWebSocket = true;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .authenticateAs(dotenv.env['MQTT_USERNAME']!, dotenv.env['MQTT_PASSWORD']!)
        .withWillQos(MqttQos.atLeastOnce);
    clientServer.keepAlivePeriod = 10;
    clientServer.connectionMessage = connMess;
    clientServer.onDisconnected = onDisconnected;
    clientServer.onConnected = onConnected;
    clientServer.onSubscribed = onSubscribed;
    clientServer.logging(on: true);
    clientServer.setProtocolV311();
  }

  void disconnect() {
    try {
      clientBrowser.disconnect();
      setState(() {
        mqtt_is_on_line = false;
      });
    } catch (e) {}
    try {
      clientServer.disconnect();
      setState(() {
        mqtt_is_on_line = false;
      });
    } catch (e) {}
    print('Disconnected');
  }

  void onConnected() {
    setState(() {
      mqtt_is_on_line = true;
    });

    BotToast.showText(
      text: '${json_qrcode['mqtt']} 連接成功',
      duration: Duration(seconds: 3),
      align: Alignment.bottomCenter,
      contentColor: Colors.green,
      textStyle: TextStyle(color: Colors.white, fontSize: 16),
    );
    print('Connected');
  }

  void onDisconnected() {
    setState(() {
      mqtt_is_on_line = false;
    });
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
