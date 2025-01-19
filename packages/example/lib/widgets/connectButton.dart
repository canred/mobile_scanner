import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bot_toast/bot_toast.dart';
import '../main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConnectButton extends StatefulWidget {
  // final bool mqttIsOnline;
  // final String deviceName;
  // final Function connectServer;
  // final Widget viewPageQrcode;
  // final Function onJsonDecoded;
  ConnectButton() : super();

  @override
  _ConnectButtonState createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> {
  @override
  Widget build(BuildContext context) {
    dotenv.load(fileName: 'assets/.env');
    print('canred mqttIsOnline: $mqttIsOnline');

    return SizedBox(
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
          onPressed: () {
            BotToast.showText(
              text: '連接失敗，請檢查網路連線。',
              duration: Duration(seconds: 3),
              align: Alignment.bottomCenter,
              contentColor: Colors.red,
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
            );
          },
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => viewPageQrcode),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: mqttIsOnline ? const Color.fromARGB(255, 246, 247, 246).withOpacity(0.7) : const Color.fromARGB(255, 247, 8, 8).withOpacity(0.5),
            shadowColor: Colors.transparent, // 設置陰影顏色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 設置按鈕圓角
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 置中對齊
            children: [
              Align(
                alignment: Alignment.centerLeft, // 將文字置中對齊
                child: Text(
                  mqttIsOnline ? '裝置連線中' : '未連接裝置',
                  style: TextStyle(
                    fontSize: 24,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft, // 將文字置中對齊
                child: Text(
                  deviceName != '' ? deviceName : "---",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 17, 17, 204),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft, // 將文字置中對齊
                child: Text(
                  '連接新電腦，請長按。',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ), // 按鈕文字
        ),
      ),
    );
  }
}
