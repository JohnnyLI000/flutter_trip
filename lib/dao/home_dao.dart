import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_trip/model/home_model.dart';

const Home_URL ='https://www.devio.org/io/flutter_app/json/home_page.json';
//首页大接口
class HomeDao{
  static Future<HomeModel> fetch() async {
    final response = await http.get(Home_URL);
    if (response.statusCode == 200) //检查接口是否成功，200 是成功
        {
      Utf8Decoder utf8decoder = Utf8Decoder(); //修复中文乱码的问题
      var result = json.decode((utf8decoder.convert(response.bodyBytes)));
      return HomeModel.fromJson(result);
    }
    else{
      throw Exception('failed to load home page json');
    }
  }
}