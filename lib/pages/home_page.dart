import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/Widget/local_nav.dart';
import 'package:flutter_trip/Widget/sales_box.dart';
import 'package:flutter_trip/Widget/search_bar.dart';
import 'package:flutter_trip/Widget/sub_nav.dart';
import 'package:flutter_trip/Widget/webview.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'dart:convert';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/Widget/grid_nav.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/Widget/loading_container.dart';
import 'package:flutter_trip/pages/search_page.dart';

const APPBAR_SCROLL_OFFSET = 100;
const SEARCH_BAR_DEFAULT_TEXT = '网红打卡点 景点 酒店 美食';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CommonModel> localNavList = [];
  List<CommonModel> bannerList = [];
  GridNavModel gridNavModel;
  List<CommonModel> subNavList = [];
  SalesBoxModel salesBoxModel;
  bool _loading = true;

  _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;

    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    } //很重要的常量变化，毕竟会小于0就是负数, 百分比，不能有大于100%和小于0%
    setState(() {
      appBarAlpha = alpha;
    });
    print(appBarAlpha);
  }

  Future<Null> _handleRefresh() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
        salesBoxModel = model.salesBox;
        bannerList = model.bannerList;
        _loading = false;
      });
    } catch (e) {
      print(e);
      _loading = false;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  double appBarAlpha = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: LoadingContainer(
            isLoading: _loading,
            child: Stack(
              children: <Widget>[
                MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: NotificationListener(
                        //监听滚动页面
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollUpdateNotification &&
                              scrollNotification.depth ==
                                  0) //等于0是因为在头顶，swiper滑动的时候会触发，所以让他排外过滤掉
                          {
                            _onScroll(scrollNotification.metrics.pixels);
                          }
                        }, //notification会监听所有child的发生的滚动
                        child: _listView,
                      ),
                    )),
                _appBar,
              ],
            )));
  }

  Widget get _listView {
    return ListView(
      children: <Widget>[
        _banner,
        Padding(
          padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
          child: localNav(
            localNavList: localNavList,
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
            child: GridNav(gridNavModel: gridNavModel)),
        Padding(
            padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
            child: SubNav(subNavList: subNavList)),
        Padding(
            padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
            child: SalesBox(salesBox: salesBoxModel)),
      ],
    );
  }

  Widget get _appBar {
    //根据滚动改变颜色
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0x66000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            height: 80.0,
            decoration: BoxDecoration(
                color:
                    Color.fromARGB((appBarAlpha * 255).toInt(), 255, 255, 255)),
            child: SearchBar(
              searchBarType: appBarAlpha > 0.2
                  ? SearchBarType.homeLight
                  : SearchBarType.home,
              inputBoxClick: _jumpToSearch,
              speakClick: _jumpToSpeak,
              defaultText: SEARCH_BAR_DEFAULT_TEXT,
              leftButtonClick: () {},
            ),
          ),
        ),
        Container(
          height: appBarAlpha > 0.2 ? 0.5 : 0,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0.5)]),
        )
      ],
    );
  }

  Widget get _banner {
    return Container(
      height: 160,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  CommonModel model = bannerList[index];
                  return WebView(
                    url: model.url,
                    statusBarColor: model.statusBarColor,
                    hideAppBar: model.hideAppBar,
                  );
                }));
              },
              child: Image.asset(
                bannerList[index].icon,
                fit: BoxFit.fill,
              ));
        },
        pagination: SwiperPagination(),
      ),
    );
  }

  _jumpToSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SearchPage(
        hint: SEARCH_BAR_DEFAULT_TEXT,
      );
    }));
  }
}

_jumpToSpeak() {}
