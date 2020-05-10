import 'package:flutter/material.dart';
import 'package:flutter_trip/Widget/search_bar.dart';
import 'package:flutter_trip/Widget/webview.dart';
import 'package:flutter_trip/dao/search_dao.dart';
import 'package:flutter_trip/model/search_model.dart';

class SearchPage extends StatefulWidget {
  final bool hideLeft;
  final String searchUrl;
  final String keyword;
  final String hint;

  const SearchPage(
      {Key key, this.hideLeft, this.searchUrl = URL, this.keyword, this.hint})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

const TYPES = [
  'attraction',
  'channeltravelsearch',
  'discount',
  'district',
  'flight',
  'food',
  'hotel',
  'play',
  'ship',
  'sight',
  'ticket',
  'train',
  'visadetail',
  'travelgroup'
];
const URL =
    'http://m.ctrip.com/restapi/h5api/searchapp/search?source=mobileweb&action=autocomplete&contentType=json&keyword=';

class _SearchPageState extends State<SearchPage> {
  SearchModel searchModel; //当前搜索返回的结果
  String keyword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        _appBar(),
        MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Expanded(
                flex: 1,
                child: ListView.builder(
                    //listview必须有一个明确的高度
                    itemCount: searchModel?.data?.length ??
                        0, //如果searchmodel和data为空，length就有一个默认值为0，否则取一个实际的长度
                    itemBuilder: (BuildContext context, int position) {
                      return _item(position);
                    })))
      ],
    ));
  }

  _onTextChange(String text) {
    keyword = text;
    if (text.length == 0) //用户清0的时候
    {
      setState(() {
        searchModel = null;
      });
      return;
    }
    String url = widget.searchUrl + text;
    SearchDao.fetch(url, text).then((SearchModel model) {
      //只有当当前输入的内容和服务端返回内容一致时才渲染
      if (model.keyword == keyword) {
        setState(() {
          searchModel = model;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  _appBar() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x66000000), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            padding: EdgeInsets.only(top: 20),
            height: 80,
            decoration: BoxDecoration(color: Colors.white),
            child: SearchBar(
              hideLeft: widget.hideLeft, //是否要隐藏返回按钮
              defaultText: widget.keyword,
              hint: widget.hint,
              leftButtonClick: () {
                Navigator.pop(context);
              },
              onChanged: _onTextChange,
            ),
          ),
        )
      ],
    );
  }

  _item(int position) {
    if (searchModel == null || searchModel.data == null) return null; //一个异常判断
    SearchItem item = searchModel.data[position];
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebView(
                      url: item.url,
                      title: 'learn more',
                    )));
      },
      child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 0.3, color: Colors.red))),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(1),
                child: Image(
                    height: 26,
                    width: 26,
                    image: AssetImage(_typeImage(item.type))),
              ),
              Column(
                children: <Widget>[
                  Container(width: 300, child: _title(item)),
                  Container(
                      width: 300,
                      child: Text(
                          '${item.word} ${item.districtName} ${item.zoneName}')),
                  Container(
                      width: 300,
                      margin: EdgeInsets.only(top: 5),
                      child: _subtitle(item)),
                ],
              )
            ],
          )),
    );
  }

  _typeImage(String type) {
    if (type == null) return 'images/type_travelgroup.png';
    String path = 'travelgroup'; //default value
    for (final val in TYPES) {
      if (type.contains(val)) {
        path = val;
        break;
      }
      return 'images/type_$path.png';
    }
  }

  _title(SearchItem item) {
    if (item == null) {
      return null;
    }
    List<TextSpan> spans = [];
    spans.addAll(_keywordTextSpans(item.word, searchModel.keyword));
    spans.add(TextSpan(
        text: ' ' + (item.districtName ?? '' + ' ' + (item.zoneName ?? '')),
        style: TextStyle(fontSize: 16, color: Colors.grey)));
    return RichText(text: TextSpan(children: spans));
  }

  _subtitle(SearchItem item) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: item.price??'',
            style: TextStyle(fontSize: 16,color:Colors.orange)
          ),
          TextSpan(
              text:' '+(item.star??'') ,
              style: TextStyle(fontSize: 12,color:Colors.green)
          ),

        ]
      ),
    );
  }
}

_keywordTextSpans(String word, String keyword) {
  List<TextSpan> spans = [];
  if (word == null || word.length == 0) return spans;
  List<String> arr = word.split(keyword);
  TextStyle normalStyle = TextStyle(fontSize: 16, color: Colors.black87);
  TextStyle keywordStyle = TextStyle(fontSize: 16, color: Colors.orange);
  for (int i = 0; i < arr.length; i++) // looking for keyword
  {
    if ((i + 1) % 2 == 0) {
      spans.add(TextSpan(text: keyword, style: keywordStyle));
    }
    String val = arr[i];
    if (val != null && val.length > 0) {
      spans.add(TextSpan(text: val, style: normalStyle));
    }
  }
  return spans;
}
