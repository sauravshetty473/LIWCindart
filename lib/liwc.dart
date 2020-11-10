library liwc;
import 'dart:core';
import 'dart:io';


export 'src/liwc_base.dart';

class LIWC{
  Map categories= {};
  Map lexiccon= {};
  String filepath;
  File file ;
  Map trie ;

  LIWC(this.filepath) {
    List temp =  _load_dict_file(filepath);
    categories = temp[0];
    lexiccon = temp[1];
    trie = build_char_trie(lexiccon);
  }

  List _load_dict_file(String filepath) {
    String temp;
    Map categories= {};
    Map lexiccon= {};
    int percentsigncount = 0;
    file =  File(filepath);
    List abc = file.readAsLinesSync().toList();
     abc.forEach((line) {
      if(line.length!=0){
        List<String> parts = line.split('\t');

        if(parts[0]=="")
          {
            parts.removeAt(0);
          }
        if (parts[0] == "%"){
          percentsigncount++;
        }
        else{
          if(percentsigncount==1){
            temp = parts[0];
            parts.removeAt(0);
            categories[temp]=parts[0];
          }
          else{
            temp = parts[0];
            parts.removeAt(0);
            lexiccon[temp]=parts;
          }
        }
      }
    });
    return [categories,lexiccon];
  }

   static Map build_char_trie(Map<dynamic , dynamic> lexiccon){
    Map trie = {};
    lexiccon.forEach((key, value) {
      Map cursor = trie;

      for(int i = 0 ; i < key.length ; i++)
        {
          if(key[i]=="*"){
            cursor["*"] = value;
            break;
          }
          if(!cursor.containsKey(key[i]))
            {
              cursor[key[i]]={};
            }
          cursor = cursor[key[i]];
        }
      cursor['\$']=value;
    });
    return trie;
  }

  static List search_trie(dynamic trie,String token,{int count=0}){
    if(trie.containsKey('*')){
      return trie['*'];
    }
    else if(trie.containsKey('\$')&&token.length==count){
      return trie['\$'];
    }
    else if(count<token.length)
      {
        if(trie.containsKey(token[count])){
          return LIWC.search_trie(trie[token[count]], token,count: count+1);
        }
      }
    return [];
  }


  List search(word){
    return search_trie(trie, word).map((e) => categories[e]).toList();
  }

  Map parse(List tokens)
  {
    Map details = {};
    tokens.forEach((element) {
      search(element).forEach((element2) {
        details[element2]=details[element2]==null?1:details[element2]+1;
      });
    });
    return details;
  }
}