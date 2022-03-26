import 'dart:convert';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:chatapp/services/user.service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors/main_color.dart';
import '../constants/size.dart';
import '../models/chatMessageModel.dart';
import '../widgets/AlertAndLoaderCustom.dart';
import '../widgets/rounded_button.dart';

enum ImageSourceType { gallery, camera }
ImagePicker picker = ImagePicker();
class ChatDetailPage extends StatefulWidget{
  final String user ;
  ChatDetailPage(this.user);
      
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
final formKey = GlobalKey<FormState>();
File? _imageFile;
String user1 = "";
TextEditingController messageController = TextEditingController();
List<ChatMessage> messages = [
    ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
    ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
    ChatMessage(messageContent: "Hey Kriss, I am doing fine dude. wbu?", messageType: "sender"),
    ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
    ChatMessage(messageContent: "Is there any thing wrong?", messageType: "sender"),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _saveUserId();
    
  }

  _saveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    print("SHARED: "+prefs.get("userId").toString());
    setState(() {
      user1 = prefs.get("userId").toString();
    });
  }

  Future<void> _handleURLButtonPressCamera(String typeUpload) async {
    final XFile? photo;
    photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 9);
    setState(() {
      _imageFile = File(photo!.path);
    });
  }

  Future<void> _handleURLButtonPressGallery(String typeUpload) async {
    final XFile? photo;
    photo =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 9);
    setState(() {
      _imageFile = File(photo!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
                SizedBox(width: 2,),
                CircleAvatar(
                  backgroundImage: NetworkImage("<https://randomuser.me/api/portraits/men/5.jpg>"),
                  maxRadius: 20,
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Kriss Benwat",style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                      SizedBox(height: 6,),
                      Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                    ],
                  ),
                ),
                Icon(Icons.settings,color: Colors.black54,),
              ],
            ),
          ),
        ),
      ),
      body: Form(
            key: formKey,
      child:Stack(
        children: <Widget>[
          ListView.builder(
  itemCount: messages.length,
  shrinkWrap: true,
  padding: EdgeInsets.only(top: 10,bottom: 10),
  physics: NeverScrollableScrollPhysics(),
  itemBuilder: (context, index){
    return Container(
      padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
      child: Align(
        alignment: (messages[index].messageType == "receiver"?Alignment.topLeft:Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (messages[index].messageType  == "receiver"?Colors.grey.shade200:Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
        ),
      ),
    );
  },
),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 20,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      showAdaptiveActionSheet(
                        context: context,
                        title: const Text(
                            'Choisir le fichier'),
                        actions: <
                            BottomSheetAction>[
                          BottomSheetAction(
                              title: const Text(
                                  'Galerie'),
                              onPressed:
                                  () async {
                                Navigator.pop(
                                    context);
                                await _handleURLButtonPressGallery(
                                    "gallery");
                              }),
                          BottomSheetAction(
                              title: const Text(
                                  'Caméra'),
                              onPressed:
                                  () async {
                                Navigator.pop(
                                    context);
                                await _handleURLButtonPressCamera(
                                    "camera");
                              }),
                        ],
                        cancelAction:
                            CancelAction(
                                title:
                                    const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors
                                  .red),
                        )), // onPressed parameter is optional by default will dismiss the ActionSheet
                      );
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 20, ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Écrire un message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: () async {
                      
                      //var number = indicator.phoneNumber.toString();
                  final isValid = formKey.currentState!.validate();
                  
                  if (isValid) {
                    
                    try {
                      //showAlertDialog(context);
                      
                      var result = await UserService.postMessage(
                        messageContent: messageController.text,
                        user1: user1,
                        user2: widget.user,
                        sender: user1,
                        img: _imageFile,
                      );
                      //Navigator.pop(context);
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (BuildContext context) =>
                      //         Login(haveNumber: false,)));
                      //print("THE RESULT: "+result);
                      return result;
                    } on SocketException catch (e) {
                      Navigator.pop(context);
                      onAlertErrorButtonPressed(
                          context, "Erreur", "Serveur inaccessible", "", false);
                    } catch (e) {
                      Navigator.pop(context);
                      final Map<String, dynamic> parsed =
                          json.decode(e.toString().substring(11));
                      var status = parsed['status'];
                      if (status == 409 || status == 404) {
                        onAlertErrorButtonPressed(
                            context, "Erreur", parsed['message'], "", false);
                      } else {
                        onAlertErrorButtonPressed(
                            context,
                            "Échoué",
                            "Votre opération a échoué. Veuillez réessayer plus tard.",
                            "",
                            false);
                      }
                    }
                  }
                    },
                    child: Icon(Icons.send,color: Colors.white,size: 18,),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
                
              ),
            ),
          ),
        ],
      ),
      )
    );
  }
}