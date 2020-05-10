import 'package:flutter/material.dart';
//加载进度条组建
class LoadingContainer extends StatelessWidget{
  final Widget child;//不在Loading的状态下，加载完，呈现的一个页面的内容
  final bool isLoading;//显示进度条还是显示具体内容
  final bool cover;//是否要覆盖整个页面的布局

  const LoadingContainer({Key key, @required this.isLoading, this.cover=false, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !cover?!isLoading?child:_loadingView //不是cover的情况下，在判断如果不是loading的情况下，就显示child，否则显示loadingview
    : Stack( //如果是cover的情况下
      children: <Widget>[child,isLoading?_loadingView:null],
    );
  }

  Widget get _loadingView{
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}