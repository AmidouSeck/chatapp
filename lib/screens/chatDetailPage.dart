import 'dart:convert';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:chatapp/services/user.service.dart';
import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors/main_color.dart';
import '../constants/size.dart';
import '../interface/messageInterface.dart';
import '../models/chatMessageModel.dart';
import '../widgets/AlertAndLoaderCustom.dart';
import "package:collection/collection.dart";

enum ImageSourceType { gallery, camera }
ImagePicker picker = ImagePicker();
class ChatDetailPage extends StatefulWidget{
  final String user ;
  final String firstname ;
  final String userFiles ;
  ChatDetailPage(this.user, this.firstname, this.userFiles);
      
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
final formKey = GlobalKey<FormState>();
UserService userService = new UserService();
File? _imageFile;
String user1 = "";
bool haveData = false;
String user2 = "";
int dateCurrent = 0;
Future<List<MessageInterface>>? msgList;
  Map<dynamic, List<MessageInterface>>? msgAllGrouped;
  List<MessageInterface> msgAll = [];
TextEditingController messageController = TextEditingController();
List<ChatMessage> messages = [
    ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
    ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
    ChatMessage(messageContent: "Hey Kriss, I am doing fine dude. wbu?", messageType: "sender"),
    ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
    ChatMessage(messageContent: "Is there any thing wrong?", messageType: "sender"),
  ];

  mainDateCurrent() {
    var now = new DateTime.now();

    dateCurrent = now.day + now.month + now.year;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mainDateCurrent();
    _saveUserId();
   
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          //waitTransaction = true;
           _getMessages();
        });
      }
    });
  }

  Future<void> _getMessages() async {
    try {
        msgList =  userService.getMessage(user1, user2);
       //print("GET MESSAGE"+msgList.toString());
       
      print(msgList);
      await msgList!.then((value) => {
            msgAll = value,
            if (mounted)
              {
            setState(() {
              msgAllGrouped =
                  groupBy(msgAll, (MessageInterface e) {
                return e.date;
              });
            }),
            },
            //waitTransaction = true,
          });
    } catch (e) {
      if (mounted) {
        setState(() {
          haveData = true;
          msgAll = [];
        });
      }
    }
  }

  _saveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      user1 = prefs.get("userId").toString();
      user2 = widget.user;
      //print("SHARED: "+user1+" "+user2);
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
    setState(() async {
      _imageFile = File(photo!.path);
      try {
                      //showAlertDialog(context);
                      
                      var result = await UserService.postMessage(
                        messageContent: messageController.text,
                        user1: user1,
                        user2: widget.user,
                        sender: user1,
                        img: _imageFile,
                      );
                      messageController.clear();
                      _getMessages();
                      //print("THE RESULT: "+result);
                      _imageFile = null;
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
                // CircleAvatar(
                //   backgroundImage: NetworkImage(widget.userFiles),
                //   maxRadius: 20,
                // ),

                 Container(
                          padding: EdgeInsets.all(10),
                          width: 50,
                          height: 50,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            // border: Border.all(color: Colors.grey, width: 0.5),
                            image: new DecorationImage(
                              image: 
                                   new AssetImage(widget.userFiles),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: null),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.firstname,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                      SizedBox(height: 6,),
                      Text("Inactif",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
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
          Padding(
              padding: EdgeInsets.only(top: 20, left: 15, right: 15),
              child: Stack(children: [
                (msgAll.length > 0)
                    ? Padding(
                        padding: EdgeInsets.only(top: 5, left: 0),
                        child: GroupListView(
                          sectionsCount:
                              msgAllGrouped!.keys.toList().length,
                          countOfItemInSection: (int section) {
                            return msgAllGrouped!.values
                                .toList()[section]
                                .length;
                          },
                          itemBuilder: _itemBuilder,
                          groupHeaderBuilder:
                              (BuildContext context, int section) {
                            var dateFrensh = DateTime.parse(
                                msgAllGrouped!.keys
                                    .toList()[section]
                                    .toString());
                            var dateTime = DateTime.parse(msgAllGrouped!.keys
                                    .toList()[section]
                                    .toString());
                            var dateTimeAll =
                                dateTime.day + dateTime.month + dateTime.year;
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 7, top: 7),
                                  child: Text(
                                    (dateTimeAll == dateCurrent)
                                        ? "Aujourd'hui"
                                        : (dateTimeAll == dateCurrent - 1)
                                            ? "Hier"
                                            : "${dateFrensh.day}/${dateFrensh.month}/${dateFrensh.year}",
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.normal,
                                        color: kPrimaryColor),
                                  ),
                                ));
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 5),
                          sectionSeparatorBuilder: (context, section) =>
                              SizedBox(height: 5),
                        ))
                    : haveData
                        ? Container(
                            // margin: EdgeInsets.only(top: 90),
                            alignment: Alignment(0.0, 0.0),
                            height: mediaHeight(context) / 2,
                            child: Text(
                              "Pas de Message",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ))
                        : Container(
                            //  margin: EdgeInsets.only(top: 90),
                            alignment: Alignment(0.0, 0.0),
                            height: mediaHeight(context) / 2,
                            child: CircularProgressIndicator(
                                color: appMainColor())),
              ])),

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
                        border: InputBorder.none,
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
                      messageController.clear();
                      _getMessages();
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


Widget _itemBuilder(BuildContext context, IndexPath index) {

    MessageInterface msg =
        msgAllGrouped!.values.toList()[index.section][index.index];
    return Container(
      padding: EdgeInsets.only(left: 14,right: 14,top: 5,bottom: 5),
      child: Align(
        alignment: (msg.sender != user1?Alignment.topLeft:Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (msg.sender  != user1?Colors.grey.shade200:Colors.blue[200]),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
          children: [
            (msg.messageContent.substring(0,6) != "/Users")  
          ?Text(msg.messageContent, style: TextStyle(fontSize: 15),)
          :Container(
            padding: EdgeInsets.all(0),
            width: 150,
            height: 150,
            decoration: new BoxDecoration(
              //shape: BoxShape.circle,
              // border: Border.all(color: Colors.grey, width: 0.5),
              image: new DecorationImage(
                image: 
                      new AssetImage(msg.messageContent),
                fit: BoxFit.cover,
              ),
            ),
            child: null),
          Container(
           width: 150,
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.bottomRight,
            child: 
          Text(
            msg.time,
             style: TextStyle(fontSize: 9),
             textAlign: TextAlign.right,),
             )
          ],
        ),
      ),
    ));
  }

}