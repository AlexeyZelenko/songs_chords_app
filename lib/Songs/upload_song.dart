import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';


import '../Persistent/persistent.dart';
import '../Services/global_methods.dart';
import '../Services/global_variables.dart';
import '../Widgets/bottom_nav_bar.dart';

final HtmlEditorController controllerEditor = HtmlEditorController();

class UploadSongNow extends StatefulWidget {

  @override
  State<UploadSongNow> createState() => _UploadSongNowState();
}

class _UploadSongNowState extends State<UploadSongNow> {

  final TextEditingController _songCategoryController = TextEditingController(text: 'Select Song Category');
  final TextEditingController _songTitleController = TextEditingController();
  final TextEditingController _songDescriptionController = TextEditingController();
  final TextEditingController _songDescriptionEditorController = TextEditingController();
  final TextEditingController _deadlineDateController = TextEditingController(text: 'Song Deadline Date');
  final TextEditingController _songYoutubeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose()
  {
    super.dispose();
    _songCategoryController.dispose();
    _songTitleController.dispose();
    _songDescriptionController.dispose();
    _songDescriptionEditorController.dispose();
    _deadlineDateController.dispose();
    _songYoutubeController.dispose();
  }

  Widget _textTitles({required String label})
  {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  })
  {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: (){
          fct();
        },
        child: TextFormField(
          validator: (value)
          {
            if(value!.isEmpty)
            {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(
            color: Colors.white,
          ),
          maxLines: valueKey == 'SongDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.black54,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              )
          ),
        ),
      ),
    );
  }

  _showTaskCategoriesDialog({required Size size})
  {
    showDialog(
        context: context,
        builder: (ctx)
        {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Song Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Persistent.songCategoryList.length,
                  itemBuilder: (ctx, index)
                  {
                    return InkWell(
                      onTap: (){
                        setState((){
                          _songCategoryController.text = Persistent.songCategoryList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_right_alt_outlined,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Persistent.songCategoryList[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              ),
            ),
            actions: [
              TextButton(
                onPressed: ()
                {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Cancel', style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                ),
              ),
            ],
          );
        }
    );
  }

  void _pickDateDialog() async
  {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 0),
      ),
      lastDate: DateTime(2100),
    );

    if(picked != null)
    {
      setState(()
      {
        _deadlineDateController.text = '${picked!.year} - ${picked!.month} - ${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _uploadTask() async
  {
    final songId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if(isValid)
    {
      if(_deadlineDateController.text == 'Choose song Deadline date' || _songCategoryController.text == 'Choose song category')
      {
        GlobalMethod.showErrorDialog(
            error: 'Please pick everything', ctx: context
        );
        return;
      }
      setState((){
        _isLoading = true;
      });
      try
      {
        await FirebaseFirestore.instance.collection('songs').doc(songId).set({
          'songId': songId,
          'uploadedBy': _uid,
          'email': user.email,
          'songTitle': _songTitleController.text,
          'songDescription': _songDescriptionController.text,
          // 'songDescriptionEditor': _songDescriptionEditorController.text,
          'songDescriptionEditor': await controllerEditor.getText(),
          'songYoutube': _songYoutubeController.text,
          'deadlineDate': _deadlineDateController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'songCategory': _songCategoryController.text,
          'songComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });
        await Fluttertoast.showToast(
          msg: 'The task has been uploaded',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _songTitleController.clear();
        // _songDescriptionController.clear();
        _songDescriptionEditorController.clear();
        setState((){
          _songCategoryController.text = 'Choose song category';
          _deadlineDateController.text = 'Choose song Deadline date';
        });
      }catch(error){
        {
          setState((){
            _isLoading = false;
          });
          GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        }
      }
      finally
      {
        setState((){
          _isLoading = false;
        });
      }
    }
    else
    {
      print('Its not valid');
    }
  }

  void getMyData() async
  {
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final userData = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    setState((){
      name = userData['name'];
      userImage = userData['userImage'];
      location = userData['location'];
    });
  }

  @override
  void initState() {
    getMyData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2,),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Please fill all fields',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Signatra',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'Song Category :'),
                            _textFormFields(
                              valueKey: 'SongCategory',
                              controller: _songCategoryController,
                              enabled: false,
                              fct: (){
                                _showTaskCategoriesDialog(size: size);
                              },
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Song Title :'),
                            _textFormFields(
                              valueKey: 'SongTitle',
                              controller: _songTitleController,
                              enabled: true,
                              fct: (){},
                              maxLength: 100,
                            ),
                            // _textTitles(label: 'Song Description :'),
                            // _textFormFields(
                            //   valueKey: 'SongDescription',
                            //   controller: _songDescriptionController,
                            //   enabled: true,
                            //   fct: (){},
                            //   maxLength: 100,
                            // ),
                            _textTitles(label: 'Song Description :'),
                            HtmlEditor(
                              // controllerEditor: _songDescriptionEditorController,
                              controller: controllerEditor,
                              htmlEditorOptions: const HtmlEditorOptions(
                                hint: 'Your text here...',
                                shouldEnsureVisible: true,
                                // initialText: "<p>text content initial, if any</p>",
                              ),
                              htmlToolbarOptions: HtmlToolbarOptions(
                                toolbarPosition: ToolbarPosition.belowEditor, //by default
                                toolbarType: ToolbarType.nativeGrid, //by default
                                onButtonPressed:
                                    (ButtonType type, bool? status, Function? updateStatus) {
                                  print(
                                      "button '${describeEnum(type)}' pressed, the current selected status is $status");
                                  return true;
                                },
                                onDropdownChanged: (DropdownType type, dynamic changed,
                                    Function(dynamic)? updateSelectedItem) {
                                  print(
                                      "dropdown '${describeEnum(type)}' changed to $changed");
                                  return true;
                                },
                                mediaLinkInsertInterceptor:
                                    (String url, InsertFileType type) {
                                  print(url);
                                  return true;
                                },
                                mediaUploadInterceptor:
                                    (PlatformFile file, InsertFileType type) async {
                                  print(file.name); //filename
                                  print(file.size); //size in bytes
                                  print(file.extension); //file extension (eg jpeg or mp4)
                                  return true;
                                },
                              ),
                              otherOptions: OtherOptions(height: 550),
                              callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                                print('html before change is $currentHtml');
                              }, onChangeContent: (String? changed) {
                                print('content changed to $changed');
                              }, onChangeCodeview: (String? changed) {
                                print('code changed to $changed');
                              }, onChangeSelection: (EditorSettings settings) {
                                print('parent element is ${settings.parentElement}');
                                print('font name is ${settings.fontName}');
                              }, onDialogShown: () {
                                print('dialog shown');
                              }, onEnter: () {
                                print('enter/return pressed');
                              }, onFocus: () {
                                print('editor focused');
                              }, onBlur: () {
                                print('editor unfocused');
                              }, onBlurCodeview: () {
                                print('codeview either focused or unfocused');
                              }, onInit: () {
                                print('init');
                              },
                                  //this is commented because it overrides the default Summernote handlers
                                  /*onImageLinkInsert: (String? url) {
                    print(url ?? "unknown url");
                  },
                  onImageUpload: (FileUpload file) async {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                    print(file.base64);
                  },*/
                                  onImageUploadError: (FileUpload? file, String? base64Str,
                                      UploadError error) {
                                    print(describeEnum(error));
                                    print(base64Str ?? '');
                                    if (file != null) {
                                      print(file.name);
                                      print(file.size);
                                      print(file.type);
                                    }
                                  }, onKeyDown: (int? keyCode) {
                                    print('$keyCode key downed');
                                    print(
                                        'current character count: ${controllerEditor.characterCount}');
                                  }, onKeyUp: (int? keyCode) {
                                    print('$keyCode key released');
                                  }, onMouseDown: () {
                                    print('mouse downed');
                                  }, onMouseUp: () {
                                    print('mouse released');
                                  }, onNavigationRequestMobile: (String url) {
                                    print(url);
                                    return NavigationActionPolicy.ALLOW;
                                  }, onPaste: () {
                                    print('pasted into editor');
                                  }, onScroll: () {
                                    print('editor scrolled');
                                  }),
                              plugins: [
                                SummernoteAtMention(
                                    getSuggestionsMobile: (String value) {
                                      var mentions = <String>['test1', 'test2', 'test3'];
                                      return mentions
                                          .where((element) => element.contains(value))
                                          .toList();
                                    },
                                    mentionsWeb: ['test1', 'test2', 'test3'],
                                    onSelect: (String value) {
                                      print(value);
                                    }),
                              ],
                            ),
                            _textTitles(label: 'Song Deadline Date :'),
                            _textFormFields(
                              valueKey: 'Deadline',
                              controller: _deadlineDateController,
                              enabled: false,
                              fct: (){
                                _pickDateDialog();
                              },
                              maxLength: 100,
                            ),
                            _textTitles(label: 'Song Youtube Link/Code :'),
                            _textFormFields(
                              valueKey: 'SongYoutubeLink',
                              controller: _songYoutubeController,
                              enabled: true,
                              fct: (){},
                              maxLength: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : MaterialButton(
                          onPressed: (){
                            _uploadTask();
                          },
                          color: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Post Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    fontFamily: 'Signatra',
                                  ),
                                ),
                                SizedBox(width: 9,),
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}