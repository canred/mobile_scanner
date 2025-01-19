import 'package:flutter/cupertino.dart';

class PtsLingJian extends StatelessWidget {
  const PtsLingJian({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('PTS-零件上機/下機'),
      ),
      child: Center(
        child: CupertinoButton(
          child: Text('按鈕'),
          onPressed: () {
            // 按鈕的處理邏輯
          },
        ),
      ),
    );
  }
}
