class  ScreensModel {
  int id;
  String screenName;
  String screenDesc;
  ScreenType screenType;
  int order;

  ScreensModel({this.id, this.screenName, this.screenDesc, this.screenType, this.order});
}


enum ScreenType { 
   actionbar_popupmenu, 
   actionbar_tabbar
}