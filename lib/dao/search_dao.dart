import 'dart:async';
import 'dart:convert';
import 'package:flutter_trip/model/search_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_trip/model/home_model.dart';

//搜索大接口
class SearchDao{
  static Future<SearchModel> fetch(String url,String text) async {
    final response = await http.get(url);
    if (response.statusCode == 200) //检查接口是否成功，200 是成功
        {
      Utf8Decoder utf8decoder = Utf8Decoder(); //修复中文乱码的问题
      var result = json.decode((utf8decoder.convert(response.bodyBytes)));
      //只有当当前输入的内容和服务端返回内容一致时才渲染
      SearchModel model = SearchModel.fromJson(result);
      model.keyword = text;
      return model;
    }
    else{
      throw Exception('failed to load search page json');
    }
  }
}