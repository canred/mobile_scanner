import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'vision_detector_views/barcode_scanner_view.dart';
import 'vision_detector_views/qrcode_scanner_view.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late MqttBrowserClient clientBrowser;
late MqttServerClient clientServer;
late bool mqtt_is_on_line = false;
late Map<String, dynamic> json_qrcode = {};
String deviceInfo = 'Loading...';
String deviceName = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  await Hive.initFlutter();
  var box = await Hive.openBox('myBox');
  // 新計入100筆資料
  var uuid = Uuid();
  var now = DateTime.now();
  var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
  for (int i = 0; i < 100; i++) {
    var item = {
      'id': uuid.v4(),
      'barcode': uuid.v4(),
      'scan_dt': formattedDate,
      'ack': 'enter',
    };
    await box.put('item_$i', item);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(), // 初始化 BotToast
      debugShowCheckedModeBanner: false,
      navigatorObservers: [BotToastNavigatorObserver()], // 添加 BotToast 觀察者
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Widget _viewPage_bc = BarcodeScannerView();
  late Widget _viewPage_qrcode;

  _HomeState() {
    if (kIsWeb) {
      connect_Browser();
    } else {
      //connect_Server(json_qrcode['mqtt'], json_qrcode['topic']);
    }
    _getDeviceInfo().then((value) => {deviceName = deviceInfo.split(':')[1].trim()});
  }

  Future<void> connect_Server(String mqtt_ip, String topic) async {
    setupMqttClient_Server(mqtt_ip, topic);
    try {
      await clientServer.connect();
      setState(() {
        mqtt_is_on_line = true;
      });
    } on NoConnectionException catch (e) {
      print('NoConnectionException:$e');
      clientServer.disconnect();
    } on SocketException catch (e) {
      print('SocketException:$e');
      clientServer.disconnect();
    } on Exception catch (e) {
      print('Exception:$e');
      clientServer.disconnect();
    } catch (e) {
      print('Error:$e');
      clientServer.disconnect();
    }
  }

  void setupMqttClient_Browser() {
    clientBrowser = MqttBrowserClient(dotenv.env['MQTT_SERVER_URL']!, 'flutter_client');
    clientBrowser.port = int.parse(dotenv.env['MQTT_PORT']!);
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .keepAliveFor(10)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .authenticateAs(dotenv.env['MQTT_USERNAME']!, dotenv.env['MQTT_PASSWORD']!)
        .withWillQos(MqttQos.atLeastOnce);
    clientBrowser.connectionMessage = connMess;
    clientBrowser.onDisconnected = onDisconnected;
    clientBrowser.onConnected = onConnected;
    clientBrowser.onSubscribed = onSubscribed;
    clientBrowser.logging(on: true);
    clientBrowser.setProtocolV311();
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

  Future<void> connect_Browser() async {
    setupMqttClient_Browser();
    try {
      await clientBrowser.connect();
      setState(() {
        mqtt_is_on_line = true;
      });
    } on NoConnectionException catch (e) {
      print('NoConnectionException:$e');
      clientBrowser.disconnect();
    } on SocketException catch (e) {
      print('SocketException:$e');
      clientBrowser.disconnect();
    } on Exception catch (e) {
      print('Exception:$e');
      clientBrowser.disconnect();
    } catch (e) {
      print('Error:$e');
      clientBrowser.disconnect();
    }
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

  void publishMessage_bowser(String topic, String message) {
    try {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      clientBrowser.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      BotToast.showText(
        text: '訊息已經發送',
        duration: Duration(seconds: 3),
        align: Alignment.bottomCenter,
        contentColor: Colors.green,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      );
      setState(() {
        mqtt_is_on_line = true;
      });
    } catch (e) {
      setState(() {
        mqtt_is_on_line = false;
      });
      BotToast.showText(
        text: '有異常 publishMessage_bowser',
        duration: Duration(seconds: 6),
        align: Alignment.bottomCenter,
        contentColor: Colors.red,
        textStyle: TextStyle(color: Colors.black, fontSize: 16),
      );
    }
  }

  void publishMessage_server(String topic, String message) {
    try {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      clientServer.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      //_getDeviceInfo().then((value) => {print(deviceInfo.split(':')[1].trim())});
      BotToast.showText(
        text: '\n訊息已經發送\n',
        duration: Duration(seconds: 3),
        align: Alignment.bottomCenter,
        contentColor: Colors.green,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      );
      setState(() {
        mqtt_is_on_line = true;
      });
    } catch (e) {
      setState(() {
        mqtt_is_on_line = false;
      });
      BotToast.showText(
        text: '有異常 publishMessage_bowser',
        duration: Duration(seconds: 6),
        align: Alignment.bottomCenter,
        contentColor: Colors.red,
        textStyle: TextStyle(color: Colors.black, fontSize: 16),
      );
    }
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String info;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        info = 'Android Device: ${androidInfo.model}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        info = 'iOS Device: ${iosInfo.utsname.machine}';
      } else {
        info = 'Unsupported platform';
      }
    } catch (e) {
      info = 'Failed to get device info: $e';
    }

    setState(() {
      deviceInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VIS Scanner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // 將所有物件向上對齊
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        this._viewPage_qrcode = QrcodeScannerView(onJsonDecoded: (json) {
                          json_qrcode = json;
                          connect_Server(json_qrcode['mqtt'], json_qrcode['topic']);
                        });

                        Navigator.push(context, MaterialPageRoute(builder: (context) => this._viewPage_qrcode));
                      },
                      child: Text('連接裝置'),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => this._viewPage_bc));
                      },
                      child: Text('掃描條碼'),
                    ),
                  ],
                ),
                kIsWeb ? Text('Web') : Text('Mobile'),
                Divider(),
                mqtt_is_on_line
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('MQTT is on line'),
                          SizedBox(width: 8),
                          Icon(Icons.circle, color: Colors.green, size: 20),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('MQTT is off line'),
                          SizedBox(width: 8),
                          Icon(Icons.circle, color: Colors.red, size: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (kIsWeb) {
                                connect_Browser();
                              } else {
                                connect_Server(json_qrcode['mqtt'], json_qrcode['topic']);
                              }
                            },
                            child: Text('連接MQTT'),
                          ),
                        ],
                      ),
                Divider(),
                ValueListenableBuilder(
                  valueListenable: Hive.box('myBox').listenable(),
                  builder: (context, Box box, _) {
                    if (box.isEmpty) {
                      return Center(child: Text('No data'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        var item = box.getAt(index);
                        return Column(
                          children: [
                            ListTile(
                              title: Text('掃描時間：' + item['scan_dt']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('條碼內容：' + item['barcode']),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.bookmark, color: Colors.green),
                                        onPressed: () {
                                          // 左邊按鈕的處理邏輯
                                        },
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              // 右邊按鈕1的處理邏輯
                                            },
                                          ),
                                          kIsWeb
                                              ? IconButton(
                                                  icon: Icon(Icons.send, color: Colors.yellow),
                                                  onPressed: () {
                                                    publishMessage_bowser("barcode/" + json_qrcode["topic"], """{"sendkey":"${item['barcode']}","ack":"${item['ack']}"}""");
                                                    // 右邊按鈕2的處理邏輯
                                                  },
                                                )
                                              : IconButton(
                                                  icon: Icon(
                                                    Icons.send,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () {
                                                    publishMessage_server("barcode/" + json_qrcode["topic"], """{"sendkey":"${item['barcode']}","ack":"${item['ack']}"}""");
                                                    // 右邊按鈕2的處理邏輯
                                                  },
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      // 按鈕1的處理邏輯
                    },
                    child: Icon(Icons.home),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: kBottomNavigationBarHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      // 按鈕1的處理邏輯
                    },
                    child: Icon(Icons.history),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (!featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('This feature has not been implemented yet')));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}
