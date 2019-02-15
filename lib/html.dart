import './widget.dart';


class H5Head implements Widget{
  String title;
  List<String> css;

  H5Head({this.title,this.css}){
    title = title ?? '';
    css = css ?? [];
  }

  
  @override
  String build(state){
    var linkCSSText = css.map((uri) => '<link herf="$uri" rel="stylesheet" type="text/css" media="all">')
        .join("\n");
    if (state['post'] != null){
      var postTitle = state['post'].titleForHuman;
      if(title != null && title.isNotEmpty){
        title = "$postTitle - $title";
      } else {
        title = postTitle;
      }
    }
    return "<head>\n" +
        '<meta encoding="utf8"/>\n' +
        '${title!=null? "<title>"+title+"</title>": ""}' +
        '$linkCSSText' +
        "</head>";
  }
}


class Body implements Widget{
  List<String> js;
  List<Widget> subwidget;

  Body(this.subwidget,{this.js: null});
  
  @override
  String build(state){
    return "<body>" +
        widget_build(subwidget,state) +
        ((js??[]) as List<String>).map((uri) => '<script src="$uri"></script>').join("\n") +
        "</body>";
  }
}

