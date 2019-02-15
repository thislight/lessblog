import 'dart:io';
import 'dart:async';
import 'dart:convert';
import './widget.dart';

class Post {
  bool isChanged = false;
  String title;
  String get titleForHuman => title.replaceAll("-"," ");
  DateTime createdTime;
  DateTime lastChangedTime;
  String text;

  Map toJson(){
    return {
      "title": title,
      "createdTime": createdTime.toIso8601String(),
      "lastChangedTime": lastChangedTime.toIso8601String(),
      "text": text
    };
  }

  Post(this.title,this.createdTime,this.lastChangedTime,this.text);
}


_hasKey(String key){
  return (Map map) => map.containsKey(key);
}


class Database {
  String websiteTitle;
  String name;
  List<Post> posts = [];

  Database();

  Future scanPosts() async{
    var plcachef = new File("posts.json"); // Post List Cache File
    if (!plcachef.existsSync()){
      await plcachef.writeAsString('{"posts":[]}');
    }
    List plcache = (await (plcachef.readAsString()).then(JSON.decode))['posts'];
    var postdir = new Directory("posts");
    if(!postdir.existsSync())
      await postdir.create();
    await for(var entrity in postdir.list()){
      if (FileSystemEntity.isFileSync(entrity.path)){
        var f = new File(entrity.path);
        var text = await f.readAsString();
        var title = f.uri.pathSegments.last.split('.').first;
        DateTime createdTime,lastChangedTime;
        bool isChanged = false;
        if (!plcache.any(_hasKey(title))){
          createdTime = new DateTime.now();
          lastChangedTime = createdTime;
        } else {
          var cached = plcache.firstWhere(_hasKey(title));
          createdTime = cached['createdTime'];
          if (cached['text'] == text){
            lastChangedTime = DateTime.parse(cached['lastChangedTime']);
          } else {
            lastChangedTime = new DateTime.now();
            isChanged = true;
          }
        }
        var post = new Post(title,createdTime,lastChangedTime,text);
        if (isChanged) post.isChanged = true;
        posts.add(post);
      }
    }
    await plcachef.writeAsString(JSON.encode({
      "posts": posts
    }));
  }

  Future scanInfomation() async{
    Map info = await (new File("blog.json")).readAsString().then(JSON.decode);
    websiteTitle = info["website"] ?? "Less is More";
    name = info["name"] ?? "LessBlog";
  }

  Future scan(){
    return Future.wait([
      scanInfomation(),
      scanPosts(),
    ]);
  }
}


class Blog {
  Map<String,Page> pages = {};
  Map config;
  List<Plugin> plugins;
  Database database = new Database();

  Blog({
    this.plugins: null,
    this.config: null
  }){
    plugins = plugins ?? [];
    config = config ?? {};
  }

  Future ready() async {
    await database.scan();
  }

  void loadPlugins(){
    for (var plugin in plugins)
      plugin.init(this);
  }

  Future compile() async {
    var pubdir = new Directory("public");
    if (pubdir.existsSync())
      await pubdir.delete(recursive: true);
    var fgw = [];
    for (var key in pages.keys){
      var file = new File("public/$key");
      await file.create(recursive: true);
      var page = pages[key];
      if (page.head == null){
        page.head = config['html_head'];
      }
      fgw.add(file.writeAsString(pages[key].build({
                    'page': page,
                    'path': key,
                    'blog': this
      })));
    }
    await Future.wait(fgw);
  }
}


class Page implements Widget{
  Widget head = null;
  List<Widget> widgets;
  Map extraState;

  Page(this.widgets,[this.extraState = null]){
    extraState = extraState ?? {};
  }
  
  @override
  String build(state){
    state.addAll(extraState);
    var str = widget_build(widgets,state);
    return "<!DOCTYPE html>\n"
        "<html>\n"
        "${head!=null?head.build(state):''}"
        "$str\n"
        "</html>\n";
  }
}


abstract class Plugin{
  void init(Blog blog);
}


class PostPagePlugin implements Plugin {
  List<Widget> widgets;

  PostPagePlugin([this.widgets]);

  @override
  void init(Blog blog){
    var widgets = this.widgets ?? blog.config['template_post'];
    for (var post in blog.database.posts){
      var page = new Page(widgets,{
        'post': post,
      });
      blog.pages[makePath(post.title)] = page;
    }
  }

  static String makePath(String title){
    return "posts/$title.html";
  }
}


class IndexPagePlugin implements Plugin {
  List<Widget> itemWidgets;
  List<Widget> head;
  List<Widget> foot;

  IndexPagePlugin({this.head,this.itemWidgets,this.foot});

  @override
  void init(Blog blog){
    var posts = blog.database.posts;
    posts.sort((a,b) => a.createdTime.compareTo(b.createdTime));
    var wlist = [];
    wlist.addAll(head);
    wlist.add(new WidgetList(new WidgetBox(itemWidgets),"post",posts));
    wlist.addAll(foot);
    blog.pages['index.html'] = new Page(wlist);
  }
}

