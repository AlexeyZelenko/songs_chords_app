import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Songs/songs_screen.dart';
import '../Widgets/song_widget.dart';


class SearchScreen extends StatefulWidget {

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  Widget _buildSearchField()
  {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for songs....',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions()
  {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: (){
          _clearSearchQuery();
        },
      ),
    ];
  }

  void _clearSearchQuery()
  {
    setState((){
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery)
  {
    setState((){
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.deepOrange.shade300, Colors.blueAccent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.2, 0.9],
      ),
    ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            ),
          ),
          leading: IconButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SongScreen()));
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: _buildSearchField(),
          actions: _buildActions(),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('songs')
              .where('songTitle', isGreaterThanOrEqualTo: searchQuery)
              .where('recruitment', isEqualTo: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot)
          {
            if(snapshot.connectionState == ConnectionState.waiting)
            {
              return const Center(child: CircularProgressIndicator(),);
            }
            else if (snapshot.connectionState == ConnectionState.active)
            {
              if(snapshot.data?.docs.isNotEmpty == true)
              {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    return SongWidget(
                      songTitle: snapshot.data?.docs[index]['songTitle'],
                      songDescription: snapshot.data?.docs[index]['songDescription'],
                      songId: snapshot.data?.docs[index]['songId'],
                      uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                      userImage: snapshot.data?.docs[index]['userImage'],
                      name: snapshot.data?.docs[index]['name'],
                      recruitment: snapshot.data?.docs[index]['recruitment'],
                      email: snapshot.data?.docs[index]['email'],
                      location: snapshot.data?.docs[index]['location'],
                    );
                  },
                );
              }
              else
              {
                return const Center(
                  child: Text('There is no songs'),
                );
              }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
              ),
            );
          },
        ),
      ),
    );
  }
}