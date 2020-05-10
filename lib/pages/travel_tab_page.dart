import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_trip/Widget/loading_container.dart';
import 'package:flutter_trip/Widget/webview.dart';
import 'package:flutter_trip/dao/travel_dao.dart';
import 'package:flutter_trip/dao/travel_tab_dao.dart';
import 'package:flutter_trip/model/travel_model.dart';
import 'package:flutter_trip/model/travel_tab_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const _TRAVEL_URL =
    'https://m.ctrip.com/restapi/soa2/16189/json/searchTripShootListForHomePageV2?_fxpcqlniredt=09031010211161114530&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650013707&__gw_plat';
const PAGE_SIZE = 0;

class TravelTabPage extends StatefulWidget {
  final String travelUrl;
  final String groupChannelCode;
  final int type;
  const TravelTabPage(
      {Key key, this.travelUrl, this.groupChannelCode, this.type})
      : super(key: key);

  @override
  _TravelTabPageState createState() => _TravelTabPageState();
}

class _TravelTabPageState extends State<TravelTabPage> with AutomaticKeepAliveClientMixin {
  List<TravelItem> travelItems;
  int pageIndex = 1;
  bool _loading = true;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _loadData();
    _scrollController.addListener((){//上拉刷新
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent)//找到临界点
        {
          _loadData(loadMore: true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    //页面销毁的时候，对controller进行一个回收，防止页面关闭，影响性能
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: LoadingContainer(
       isLoading: _loading,
         child: RefreshIndicator(//下拉刷新
           onRefresh: _handleRefresh,
             child:MediaQuery.removePadding(
                 removeTop: true,
                 context: context,
                 child: StaggeredGridView.countBuilder(
                   controller: _scrollController,
                   crossAxisCount: 4,
                   itemCount: travelItems?.length ?? 0, //不等于空的情况下返回，默认值为0
                   itemBuilder: (BuildContext context, int index) =>
                       _TravelItem(index: index, item: travelItems[index]),
                   staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                 )))
         )
    );
  }

  void _loadData({loadMore = false}) { //loadmore 是dart 的默认语法
    if(loadMore){//上拉加载更多，页面加1
      pageIndex++;
    }else{
      pageIndex=1;
    }
    TravelDao.fetch(widget.travelUrl ?? _TRAVEL_URL, params,
            widget.groupChannelCode, widget.type, pageIndex, PAGE_SIZE)
        .then((TravelItemModel model) {
          _loading= false;
      setState(() {
        List<TravelItem> items = _filterItems(model.resultList);
        if (travelItems != null) {
          travelItems.addAll(items);
        } else {
          travelItems = items;
        }
      });
    }).catchError((e) {
      _loading= false;
      print(e);
    });
  }

  List<TravelItem> _filterItems(List<TravelItem> resultList) {
    if (resultList == null) {
      return [];
    }
    List<TravelItem> filterItems = [];
    resultList.forEach((item) {
      if (item.article != null) //移除article为空的东西
      {
        filterItems.add(item);
      }
    });
    return filterItems;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;//把数据都保存在内存里

  Future<Null> _handleRefresh() async {
    _loadData();
    return null;
  }
}

class _TravelItem extends StatelessWidget {
  final TravelItem item;
  final int index;

  const _TravelItem({Key key, this.item, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.article.urls != null && item.article.urls.length > 0) {
          Navigator.push(
              (context),
              MaterialPageRoute(
                  builder: (context) => WebView(
                        url: item.article.urls[0].h5Url,
                        title: '详情',
                      )));
        }
      },
      child: Card(
        child: PhysicalModel(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_itemImage(),
            Container(
              padding: EdgeInsets.all(4),
              child: Text(item.article.articleTitle,
              maxLines: 2,
                  overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14,color:Colors.black54),),
            ),
            _infoText()],
          ),
        ),
      ),
    );
  }

  _itemImage() {
    return Stack(
      children: <Widget>[
        Image.network(item.article.images[0]?.dynamicUrl),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                LimitedBox(//显示文字的时候有。。。。这种
                  maxWidth: 130,
                  child: Text(
                    _poiName(),
                    maxLines: 1, //不会有换行
                    overflow: TextOverflow.ellipsis, //文字省略的形式
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  String _poiName() {
    return item.article.pois == null || item.article.pois.length == 0
        ? '未知'
        : item.article.pois[0]?.poiName ?? '未知';
  }

  _infoText() {
    return Container(
      padding: EdgeInsets.fromLTRB(6,0, 6, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              PhysicalModel(color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.article.author?.coverImage?.dynamicUrl,width: 24,height: 24,),),
              Container(
                padding: EdgeInsets.all(5),
                width: 90,
                child: Text(item.article.author?.nickName,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12),),
              )
            ],
          ),
          Row(children: <Widget>[
            Icon(Icons.thumb_up,size: 14,color: Colors.grey,),
            Padding(padding: EdgeInsets.only(left: 3),
            child: Text(item.article.likeCount.toString(),
            style: TextStyle(fontSize: 10),),)
          ],)
        ],
      ),
    );
  }
}
