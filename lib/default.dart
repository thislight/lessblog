import './widget.dart';
import './lessblog.dart';

class HomeTitle implements Widget{
  HomeTitle();

  String build(state){
    Blog blog = state['blog'];
    return "<h1>${blog.database.websiteTitle}</h1><hr />";
  }
}


class HomeLink implements Widget{
  HomeLink();

  String build(state){
    return '<a herf="/" class="home-link">Home</a><hr />';
  }
}


class PostBlock implements Widget{
  PostBlock();

  String build(state){
    Post post = state['post'];
    return '<div class="post"><hr />\n'
        '<h2>${post.titleForHuman}</h2><hr />\n'
        '<p>Created on ${post.createdTime.toIso8601String()}</p><hr />\n'
        '<p>Last changed on ${post.lastChangedTime.toIso8601String()}</p><hr />\n'
        '<p>${post.text}</p>';
  }
}


class Foot implements Widget{
  Foot();

  String build(state){
    Blog blog = state['blog'];
    return "<hr /><p>Written by ${blog.database.name}, Made with :D by LessBlog</p>";
  }
}


class PostLink implements Widget{
  PostLink();

  String build(state){
    Post post = state['post'];
    return '<a href="/posts/${post.title}.html"><h5>${post.titleForHuman}</h5></a>\n'
        '<p>${post.text.substring(0,post.text.length>60?59:post.text.length)}${post.text.length>60?"...":""}\n'
        '<hr />';
  }
}


