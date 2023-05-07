import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workspace/home_page.dart';



class ChoicePage extends StatefulWidget {
  final String buildingName;
  final String doctorName;
  final int id;


  const ChoicePage({super.key,
    required this.buildingName,
    required this.doctorName,
    required this.id});

  @override
  ChoicePageState createState() => ChoicePageState();
}

class ChoicePageState extends State<ChoicePage> {
  List<Article> _articles = [];
  int _id = 0;

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    loadArticles(_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.builder(
            itemCount: _articles.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _articles[index];
              return Container(
                  height: 136,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                  Expanded(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text("${item.author} · ${item.postedOn}",
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icons.bookmark_border_rounded,
                          Icons.share,
                          Icons.more_vert
                        ].map((e) {
                          return InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(e, size: 16),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  )),
              Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(item.imageUrl),
              ))),
                      Container(
                        margin: const EdgeInsets.all(24),
                        child: ElevatedButton(
                          onPressed: () {
                            if (true) {
                              Navigator.pop(
                                context,
                                MaterialPageRoute(builder: (context) => SearchPage()),
                              );
                            }
                          },
                          child: const Text('Next'),
                        ),
                      ),

                    ],
              )
              ,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> loadArticles(int valueID) async {
    _articles = [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('department_list', arrayContains: valueID)
        .get();
    final articleList = <Article>[];
    for (final documentSnapshot in querySnapshot.docs) {
      final buildingName = documentSnapshot.get('building_name');
      final campus = documentSnapshot.get('campus');
      final imagelink = documentSnapshot.get('image');
      final Reference storageRef = FirebaseStorage.instance.ref().child(imagelink);
      final String downloadUrl = await storageRef.getDownloadURL();
      final article = Article(
        title: buildingName,
        author: campus,
        imageUrl: downloadUrl, // Use download URL as the image URL
        postedOn: DateTime.now(),
      );
      articleList.add(article);
    }

    setState(() {
      _articles = articleList;
    });
  }



}

class Article {
  String title;
  String author;
  String imageUrl;
  DateTime postedOn;


  Article({
    required this.title,
    required this.author,
    required this.postedOn,
    required this.imageUrl,
  });
}








