import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:imagestock/models/ImageModel.dart';
import 'package:http/http.dart' as http;
import 'package:imagestock/pages/ImageDetailPage.dart';

class ImageListPage extends StatefulWidget {
  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  late Future<List<ImageModel>> _futureImages;
  final _searchController = TextEditingController();
  String _filterText = '';
  int _currentPage = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _futureImages = _fetchImages(_currentPage, _pageSize);
    _searchController.addListener(() {
      setState(() {
        _filterText = _searchController.text;
      });
    });
  }

  Future<List<ImageModel>> _fetchImages(int page, int size) async {
    final response = await http.get(Uri.parse(
        'https://64266c9f556bad2a5b4f7749.mockapi.io/photos?page=$page&limit=$size'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ImageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch images');
    }
  }

  List<ImageModel> _filterImages(List<ImageModel> images, String filterText) {
    if (filterText.isEmpty) {
      return images;
    } else {
      return images
          .where((image) => image.description
              .toLowerCase()
              .contains(filterText.toLowerCase()))
          .toList();
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _futureImages = _fetchImages(_currentPage, _pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: 'Search'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ImageModel>>(
              future: _futureImages,
              builder: (BuildContext context,
                  AsyncSnapshot<List<ImageModel>> snapshot) {
                if (snapshot.hasData) {
                  final images = _filterImages(snapshot.data!, _filterText);
                  return ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      final image = images[index];
                      return ListTile(
                        leading: Image.network(image.url),
                        title: Text(image.description),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ImageDetailPage(image: image);
                          }));
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 100.0,
                  child: new ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return TextButton(
                        onPressed: () => _onPageChanged(index + 1),
                        child: Text(index.toString()),
                      );
                    },
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ],
      ),
    );
  }
}
