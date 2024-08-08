import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie/music/provider/PlayerMusicProvider.dart';
import 'package:movie/router/index.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../model/MusicClassifyModel.dart';
import '../service/serverMethod.dart';
import '../../theme/ThemeStyle.dart';
import '../../theme/ThemeColors.dart';
import '../../theme/ThemeSize.dart';
import '../model/MusicModel.dart';
import '../../common/constant.dart';
import '../component/MusicListComponent.dart';

class MusicClassifyListPage extends StatefulWidget {
  final MusicClassifyModel musicClassifyModel;

  MusicClassifyListPage({Key key, this.musicClassifyModel}) : super(key: key);

  @override
  _MusicClassifyListPageState createState() => _MusicClassifyListPageState();
}

class _MusicClassifyListPageState extends State<MusicClassifyListPage>
    with TickerProviderStateMixin, RouteAware {
  EasyRefreshController easyRefreshController = EasyRefreshController();
  bool loading = false;
  int total = 0;
  int pageNum = 1;
  List<MusicModel> musicList = [];

  @override
  void initState() {
    useMusicList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.colorBg,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                buildTitleWidget(),
                Expanded(
                  flex: 1,
                  child: EasyRefresh(
                    controller: easyRefreshController,
                    footer: ClassicalFooter(
                      loadText: '上拉加载',
                      loadReadyText: '准备加载',
                      loadingText: '加载中...',
                      loadedText: '加载完成',
                      noMoreText: '没有更多',
                      bgColor: Colors.transparent,
                      textColor: ThemeColors.disableColor,
                    ),
                    onLoad: () async {
                      if (total > pageNum * PAGE_SIZE) {
                        pageNum++;
                        useMusicList();
                      } else {
                        Fluttertoast.showToast(
                            msg: "已经到底了",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: ThemeSize.middleFontSize);
                      }
                    },
                    child: Padding(
                      padding: ThemeStyle.padding,
                        child: MusicListComponent(musicList: musicList,classifyName: widget.musicClassifyModel.classifyName,onPlayMusic:(MusicModel musicModel,int index){
                          usePlayRouter(musicModel,index);
                    })),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  ///@author: wuwenqiang
  ///@description: 播放音乐列表
  /// @date: 2024-07-20 04:13
  usePlayRouter(MusicModel musicModel,int index)async{
    PlayerMusicProvider provider = Provider.of<PlayerMusicProvider>(context, listen: false);
    if(provider.classifyName != widget.musicClassifyModel.classifyName){
      await getMusicListByClassifyIdService(widget.musicClassifyModel.id, 1, MAX_FAVORITE_NUMBER,1).then((value) {
        provider.setClassifyMusic(value.data.map((e) => MusicModel.fromJson(e)).toList(),index,widget.musicClassifyModel.classifyName);
      });
    }else{
      provider.setPlayMusic(musicModel, true);
    }
    Routes.router.navigateTo(context, '/MusicPlayerPage');
  }

  ///@author: wuwenqiang
  ///@description: 创建头部按钮
  /// @date: 2024-07-13 17:33
  Widget buildTitleWidget() {
    return Container(
        padding: ThemeStyle.padding,
        decoration: BoxDecoration(color: ThemeColors.colorWhite),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            child: Image.asset('lib/assets/images/icon_back.png',
                width: ThemeSize.smallIcon, height: ThemeSize.smallIcon),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Text(widget.musicClassifyModel.classifyName),
          SizedBox(width: ThemeSize.smallIcon)
        ]));
  }

  ///@author: wuwenqiang
  ///@description: 加载音乐列表
  /// @date: 2024-07-13 18:16
  void useMusicList() {
    getMusicListByClassifyIdService(
            widget.musicClassifyModel.id, pageNum, PAGE_SIZE, 1)
        .then((value) {
      setState(() {
        musicList
            .addAll(value.data.map((e) => MusicModel.fromJson(e)).toList());
        total = value.total;
        easyRefreshController.finishLoad(success: true,noMore: musicList.length == total);
      });
    });
  }
}
