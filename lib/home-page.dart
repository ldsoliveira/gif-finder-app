import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gif_finder/gif-page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _query;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if(_query == null || _query.isEmpty) {
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=HYMVW1VC8gNmepvTfZvy9PC5nDL9na60&limit=20&rating=g');
    } else {
      response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=HYMVW1VC8gNmepvTfZvy9PC5nDL9na60&q=$_query&limit=19&offset=$_offset&rating=g&lang=en');
    }

    return json.decode(response.body);
  }

  Future<Null> _refresh() async {

    await Future.delayed(Duration(milliseconds: 10));

    setState(() {
      _getGifs();
      _offset += 19;
    });
  }

  int _getItemCount(List data){
    if(_query == null || _query.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif',
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            return Text('Gif finder app');
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search here",
                labelStyle: TextStyle(
                  color: Colors.white
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _query = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if(snapshot.hasError) {
                      return Container(
                        child: Center(
                          child: Text(
                            'An error has occurred, please try again.',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }
                    else {
                      return _createGifTable(context, snapshot);
                    }
                }
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    
    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ), 
        itemCount: _getItemCount(snapshot.data['data']),
        itemBuilder: (context, index) {

          final gifs = snapshot.data['data'][index]['images']['fixed_height']['url'];

          if(_query == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                height: 300.0,
                fit: BoxFit.cover,
                placeholder: kTransparentImage, 
                image: gifs,
              ),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => GifPage(snapshot.data['data'][index])
                  ),
                );
              },
              onLongPress: () {
                Share.share(gifs);
              },
            );
          } else {
            return Container(
              color: Colors.black12,
              child: GestureDetector(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 70.0,
                      ),
                      Text(
                        'Tap for more',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                    ],
                  ),
                onTap: (){
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        }
      ),
    );
  }
}