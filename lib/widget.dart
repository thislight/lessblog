

abstract class Widget{
  String build(Map state);
}


String widget_build(List<Widget> widgets,Map state){
  print(widgets);
  return widgets.map((widget) => widget.build(state)).join("\n");
}


class WidgetList implements Widget {
  Widget widget;
  List data;
  String key;

  WidgetList(this.widget,this.key,this.data);

  String build(state){
    return data.map((d){
      state[key] = d;
      return widget.build(state);
    }).join("\n");
  }
}


class WidgetBox implements Widget {
  List<Widget> widgets;

  WidgetBox(this.widgets);

  String build(state){
    return widget_build(widgets,state);
  }
}

