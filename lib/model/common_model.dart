//icon String
//title String
//url String
//statusBarColor String
//hideAppBar bool

class CommonModel {
  final String icon;
  final String title;
  final String url;
  final String statusBarColor;
  final bool hideAppBar;

  CommonModel({this.icon, this.title, this.url, this.statusBarColor, this.hideAppBar});

  factory CommonModel.fromJson(Map<String, dynamic> json) {
    return CommonModel(
        icon: json['icon'],
        title:json['title'],
        url: json['url'],
        statusBarColor: json['statusBarColor'],
        hideAppBar: json["hideAppBar"]
    );
  }
  Map<String, dynamic> toJson(){
    return{
      icon:icon,
      title:title,
      url:url,
      statusBarColor:statusBarColor,
    };
  }
}
