//icon String
//title String
//url String
//statusBarColor String
//hideAppBar bool
//搜索模型

class SearchModel{
  String keyword;
  final List<SearchItem> data;
  SearchModel({this.data});
  factory SearchModel.fromJson(Map<String, dynamic> json) {
  var dataJson = json['data'] as List;
  List<SearchItem> data = dataJson.map((i)=>SearchItem.fromJson(i)).toList();
  return SearchModel(data: data);
  }
}


class SearchItem {
  final String word;
  final String type;
  final String price;
  final String star;
  final String zoneName;
  final String districtName;
  final String url;


  SearchItem({this.word, this.type, this.price, this.star, this.zoneName,
  this.districtName, this.url});

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      word: json['word'],
      type: json['type'],
      price: json['price'],
      star: json['star'],
      zoneName: json['zonename'],
      districtName: json['districtname'],
      url:json['url']
    );
  }
}
