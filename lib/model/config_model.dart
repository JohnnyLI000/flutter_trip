//config object
//bannerList Array
//localNavList Array
//gridNav Object
//subNavList  Array
//salesBox Object

class ConfigModel {
  final String searchUrl;
  ConfigModel({this.searchUrl});

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(searchUrl: json['searchUrl']);
  }


  Map<String, dynamic> toJson(){
    return{
      searchUrl:searchUrl
    };
  }
}
