import 'package:flutter/material.dart';
import 'package:flutter_trip/Widget/webview.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:WebView(
          url: 'http://m.ctrip.com/webapp/myctrip/',
          hideAppBar: true,
          backForbid: true,
          statusBarColor: '4c5bca',
        )
    );
  }
}
