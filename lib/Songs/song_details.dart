import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:songs_chords_app/Songs/songs_screen.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



import '../Services/global_methods.dart';
import '../Services/global_variables.dart';
import '../Widgets/comments_widget.dart';

YoutubePlayerController _controllerVideo = YoutubePlayerController(
  initialVideoId: '64bBLSlX6w0',
  flags: const YoutubePlayerFlags(
    autoPlay: false,
    mute: false,
  ),
);

class SongDetailsScreen extends StatefulWidget {

  final String uploadedBy;
  final String songID;

  const SongDetailsScreen({super.key,
    required this.uploadedBy,
    required this.songID,
  });

  @override
  State<SongDetailsScreen> createState() => _SongDetailsScreenState();
}

class _SongDetailsScreenState extends State<SongDetailsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? songCategory;
  String? songDescription;
  String? songDescriptionEditor;
  String? songYoutube;
  String? songTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = '';
  String? emailCompany = '';
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;

  void getSongData() async
  {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if(userDoc == null)
    {
      return;
    }
    else
    {
      setState((){
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot songDatabase = await FirebaseFirestore.instance
        .collection('songs')
        .doc(widget.songID)
        .get();
    if(songDatabase == null)
    {
      return;
    }
    else
    {
      setState((){
        songTitle = songDatabase.get('songTitle');
        songYoutube = songDatabase.get('songYoutube');
        songDescription = songDatabase.get('songDescription');
        songDescriptionEditor = songDatabase.get('songDescriptionEditor');
        recruitment = songDatabase.get('recruitment');
        emailCompany = songDatabase.get('email');
        locationCompany = songDatabase.get('location');
        applicants = songDatabase.get('applicants');
        postedDateTimeStamp = songDatabase.get('createdAt');
        deadlineDateTimeStamp = songDatabase.get('deadlineDateTimeStamp');
        deadlineDate = songDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });
      _controllerVideo = YoutubePlayerController(
        initialVideoId: songYoutube != null ? YoutubePlayer.convertUrlToId(songYoutube!)! : '64bBLSlX6w0',
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      );

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSongData();
  }

  Widget dividerWidget()
  {
    return Column(
      children: const [
        SizedBox(height: 10,),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  applyForSong()
  {
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query: 'subject=Applying for $songTitle&body=Hello, please attach Resume CV file',
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  void addNewApplicant() async
  {
    var docRef = FirebaseFirestore.instance
        .collection('songs')
        .doc(widget.songID);

    docRef.update({
      'applicants': applicants + 1,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
            icon: const Icon(Icons.close, size: 40, color: Colors.white,),
            onPressed: ()
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SongScreen()));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            songTitle == null
                                ?
                            ''
                                :
                            songTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3,
                                  color: Colors.grey,
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    userImageUrl == null
                                        ?
                                    'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                                        :
                                    userImageUrl!,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null
                                        ?
                                    ''
                                        :
                                    authorName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    locationCompany!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6,),
                            const Text(
                              'Applicants',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 10,),
                            const Icon(
                              Icons.how_to_reg_sharp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy
                            ?
                        Container()
                            :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dividerWidget(),
                            const Text(
                              'Recruitment',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadedBy)
                                    {
                                      try
                                      {
                                        FirebaseFirestore.instance
                                            .collection('songs')
                                            .doc(widget.songID)
                                            .update({'recruitment': true});
                                      }catch (error)
                                      {
                                        GlobalMethod.showErrorDialog(
                                          error: 'Action cannot be performed',
                                          ctx: context,
                                        );
                                      }
                                    }
                                    else
                                    {
                                      GlobalMethod.showErrorDialog(
                                        error: 'You cannot perform this action',
                                        ctx: context,
                                      );
                                    }
                                    getSongData();
                                  },
                                  child: const Text(
                                    'ON',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: recruitment == true ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                TextButton(
                                  onPressed: (){
                                    User? user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadedBy)
                                    {
                                      try
                                      {
                                        FirebaseFirestore.instance
                                            .collection('songs')
                                            .doc(widget.songID)
                                            .update({'recruitment': false});
                                      }catch (error)
                                      {
                                        GlobalMethod.showErrorDialog(
                                          error: 'Action cannot be performed',
                                          ctx: context,
                                        );
                                      }
                                    }
                                    else
                                    {
                                      GlobalMethod.showErrorDialog(
                                        error: 'You cannot perform this action',
                                        ctx: context,
                                      );
                                    }
                                    getSongData();
                                  },
                                  child: const Text(
                                    'OFF',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: recruitment == false ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_box,
                                    color: Colors.red,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        dividerWidget(),
                        const Text(
                          'Song Description',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Html(
                          data: songDescriptionEditor ?? '',
                          style: {
                            'body': Style(
                              fontSize: const FontSize(14.0),
                              color: Colors.grey,
                            ),
                          },
                        ),
                        Text(
                          songDescription == null ? '': songDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        dividerWidget(),
                        YoutubePlayer(
                          controller: _controllerVideo,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.amber,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10,),
                        Center(
                          child: Text(
                            isDeadlineAvailable
                                ?
                            'Actively Recruiting, Send CV/Resume:'
                                :
                            'Deadline Passed away.',
                            style: TextStyle(
                              color: isDeadlineAvailable
                                  ?
                              Colors.green
                                  :
                              Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6,),
                        Center(
                          child: MaterialButton(
                            onPressed: (){
                              applyForSong();
                            },
                            color: Colors.blueAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Easy Apply Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Uploaded on:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              postedDate == null
                                  ?
                              ''
                                  :
                              postedDate!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Deadline date:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              deadlineDate == null
                                  ?
                              ''
                                  :
                              deadlineDate!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 500,
                          ),
                          child: _isCommenting
                              ?
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 3,
                                child: TextField(
                                  controller: _commentController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  maxLength: 200,
                                  keyboardType: TextInputType.text,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.pink),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: MaterialButton(
                                        onPressed: () async{
                                          if(_commentController.text.length < 7)
                                          {
                                            GlobalMethod.showErrorDialog(
                                              error: 'Comment cannot be less than 7 characters',
                                              ctx: context,
                                            );
                                          }
                                          else
                                          {
                                            final _generatedId = const Uuid().v4();
                                            await FirebaseFirestore.instance
                                                .collection('songs')
                                                .doc(widget.songID)
                                                .update({
                                              'songComments':
                                              FieldValue.arrayUnion([{
                                                'userId': FirebaseAuth.instance.currentUser!.uid,
                                                'commentId': _generatedId,
                                                'name': name,
                                                'userImageUrl': userImage,
                                                'commentBody': _commentController.text,
                                                'time': Timestamp.now(),
                                              }]),
                                            });
                                            await Fluttertoast.showToast(
                                              msg: 'Your comment has been added',
                                              toastLength: Toast.LENGTH_LONG,
                                              backgroundColor: Colors.grey,
                                              fontSize: 18.0,
                                            );
                                            _commentController.clear();
                                          }
                                          setState((){
                                            showComment = true;
                                          });
                                        },
                                        color: Colors.blueAccent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Post',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (){
                                        setState((){
                                          _isCommenting = !_isCommenting;
                                          showComment = false;
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                              :
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: (){
                                  setState((){
                                    _isCommenting = !_isCommenting;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add_comment,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              IconButton(
                                onPressed: (){
                                  setState((){
                                    showComment = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_drop_down_circle,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        showComment == false
                            ?
                        Container()
                            :
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('songs')
                                .doc(widget.songID)
                                .get(),
                            builder: (context, snapshot)
                            {
                              if(snapshot.connectionState == ConnectionState.waiting)
                              {
                                return const Center(child: CircularProgressIndicator(),);
                              }
                              else
                              {
                                if(snapshot.data == null)
                                {
                                  const Center(child: Text('No Comment for this song'),);
                                }
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index)
                                {
                                  return CommentWidget(
                                    commentId: snapshot.data!['songComments'] [index]['commentId'],
                                    commenterId: snapshot.data!['songComments'] [index]['userId'],
                                    commenterName: snapshot.data!['songComments'] [index]['name'],
                                    commentBody: snapshot.data!['songComments'] [index]['commentBody'],
                                    commenterImageUrl: snapshot.data!['songComments'] [index]['userImageUrl'],
                                  );
                                },
                                separatorBuilder: (context, index)
                                {
                                  return const Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  );
                                },
                                itemCount: snapshot.data!['songComments'].length,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}