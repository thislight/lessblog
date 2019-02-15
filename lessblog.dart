import 'dart:async';

import 'package:lessblog/lessblog.dart';
import 'package:lessblog/widget.dart';
import 'package:lessblog/html.dart';

import 'package:lessblog/default.dart';


final PLUG_INDEXPAGE = new IndexPagePlugin(
    head: [
      new HomeTitle()
    ],
    itemWidgets: [
      new PostLink()
    ],
    foot: []
);


final BLOG = new Blog(
    plugins: [
      new PostPagePlugin(), // For make post pages
      PLUG_INDEXPAGE,
    ],
    config: {
      'template_post': [
        new HomeLink(),
        new HomeTitle(),
        new PostBlock(),
      ],
      'html_head': new H5Head(),// Add HTML tag <head>
    }
);


main() async {
  await BLOG.ready(); // Scan database to load website infomation and posts
  BLOG.loadPlugins();
  await BLOG.compile(); // Compile posts to website
}

