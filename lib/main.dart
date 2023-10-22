import 'package:flutter/material.dart';
import 'package:gpt/list_chat.dart';
import 'package:gpt/single_chat.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chat Gpt Demo',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 選択中フッターメニューのインデックスを一時保存する用変数
  int selectedIndex = 0;

  static const String singleChatTitle = 'Single Chat';
  static const String listChatTitle = 'List Chat';

  // 切り替える画面のリスト
  List<Widget> display = [
    const SingleChat(
      title: singleChatTitle,
    ),
    const ListChat(title: listChatTitle)
  ];

  String get appBarTitle {
    return selectedIndex == 0 ? singleChatTitle : listChatTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle), // AppBarにタイトルを追加
        ),
        body: display[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: singleChatTitle),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none), label: listChatTitle),
          ],
          // 現在選択されているフッターメニューのインデックス
          currentIndex: selectedIndex,
          // フッター領域の影
          elevation: 0,
          // フッターメニュータップ時の処理
          onTap: (int index) {
            selectedIndex = index;
            setState(() {});
          },
          // 選択中フッターメニューの色
          fixedColor: Colors.red,
        ));
  }
}
