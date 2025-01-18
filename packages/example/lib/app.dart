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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CupertinoStoreApp extends StatefulWidget {
  @override
  _CupertinoStoreAppState createState() => _CupertinoStoreAppState();
}

class _CupertinoStoreAppState extends State<CupertinoStoreApp> {
  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatefulWidget {
  const CupertinoStoreHomePage({Key? key}) : super(key: key);

  @override
  _CupertinoStoreHomePageState createState() => _CupertinoStoreHomePageState();
}

class _CupertinoStoreHomePageState extends State<CupertinoStoreHomePage> {
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
                  image: AssetImage('assets/images/child_dog.jpg'), // 設置背景圖片
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0), // 設置邊框圓角
              ),
              child: CupertinoButton(
                color: CupertinoColors.activeGreen.withOpacity(0.7), // 設置底色並調整透明度
                onPressed: () => {},
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                borderRadius: BorderRadius.circular(8.0), // 設置邊框圓角
                child: Text(
                  '連接裝置\n掃描條碼',
                  style: TextStyle(fontSize: 24),
                ), // 按鈕文字
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
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/child_dog.jpg', // 替換為你的按鈕底圖路徑
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '功能按鈕 ',
                          style: TextStyle(color: CupertinoColors.black),
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
                          child: Image.asset(
                            'assets/images/child_dog.jpg', // 替換為你的按鈕底圖路徑
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '功能按鈕 ',
                          style: TextStyle(color: CupertinoColors.black),
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
                          child: Image.asset(
                            'assets/images/child_dog.jpg', // 替換為你的按鈕底圖路徑
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '功能按鈕 ',
                          style: TextStyle(color: CupertinoColors.black),
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
                          child: Image.asset(
                            'assets/images/child_dog.jpg', // 替換為你的按鈕底圖路徑
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '功能按鈕 ',
                          style: TextStyle(color: CupertinoColors.black),
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
                          child: Image.asset(
                            'assets/images/child_dog.jpg', // 替換為你的按鈕底圖路徑
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '功能按鈕 ',
                          style: TextStyle(color: CupertinoColors.black),
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
                          child: Image.asset(
                            'assets/images/child_dog.jpg', // 替換為你的按鈕底圖路徑
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          '功能按鈕 ',
                          style: TextStyle(color: CupertinoColors.black),
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
}
