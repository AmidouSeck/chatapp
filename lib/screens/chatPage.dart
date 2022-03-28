import 'package:chatapp/screens/addContact.dart';
import 'package:chatapp/screens/chatDetailPage.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import '../constants/colors/main_color.dart';
import '../constants/size.dart';
import '../interface/userInterface.dart';
import '../models/chatUsersModel.dart';
import '../services/user.service.dart';
import '../widgets/conversationList.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:easy_mask/easy_mask.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

UserService userService = new UserService();
Future<List<UserInterface>>? userList;
  Map<dynamic, List<UserInterface>>? userAllGrouped;
  List<UserInterface> userAll = [];
  //List<> list = [];
  int dateCurrent = 0;
  Future<UserInterface>? userInfos;
  bool haveData = false;
  bool waitTransaction = false;
  
List chatUsers = [
    // ChatUsers(name: "Jane Russel", messageText: "Awesome Setup", image: "assets/images/smile_success.png", time: "Now"),
    // ChatUsers(name: "Glady's Murphy", messageText: "That's Great", image: "assets/images/smile_success.png", time: "Yesterday"),
    // ChatUsers(name: "Jorge Henry", messageText: "Hey where are you?", image: "assets/images/smile_success.png", time: "31 Mar"),
    // ChatUsers(name: "Philip Fox", messageText: "Busy! Call me in 20 mins", image: "assets/images/smile_success.png", time: "28 Mar"),
    // ChatUsers(name: "Debra Hawkins", messageText: "Thankyou, It's awesome", image: "assets/images/smile_success.png", time: "23 Mar"),
    // ChatUsers(name: "Jacob Pena", messageText: "will update you in evening", image: "assets/images/smile_success.png", time: "17 Mar"),
    // ChatUsers(name: "Andrey Jones", messageText: "Can you please share the file?", image: "assets/images/smile_success.png", time: "24 Feb"),
    // ChatUsers(name: "John Wick", messageText: "How are you?", image: "assets/images/smile_success.png", time: "18 Feb"),
  ];
  mainDateCurrent() {
    var now = new DateTime.now();

    dateCurrent = now.day + now.month + now.year;
  }
  

  Future<void> _getUsers() async {
    try {
      userList = userService.getUsers();
      //chatUsers = userList as List<UserInterface>;
      // print("THE INFO");
      // print(userList);
      await userList!.then((value) => {
            userAll = value,
            if (mounted)
              {
            setState(() {
              userAllGrouped =
                  groupBy(userAll, (UserInterface e) {
                return e.created_at;
              });
            }),
            },
            waitTransaction = true,
          });
    } catch (e) {
      if (mounted) {
        setState(() {
          haveData = true;
          userAll = [];
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  mainDateCurrent();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          //waitTransaction = true;
          _getUsers();
        });
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(children: [
            Padding(
                padding: EdgeInsets.only(left: 30,right: 16,top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Contacts",style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),),
                    Container(
                      //padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink[50],
                      ),
                      child: Row(
                        children: <Widget>[
                          //Icon(Icons.add,color: Colors.pink,size: 20,),
                          //SizedBox(width: 2,),
                          //Text("Ajouter",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                          ElevatedButton(
                            style: ButtonStyle(
                              // backgroundColor:
                              //     MaterialStateProperty
                              //         .all(
                              //             Colors.pink.shade100),
                              shape: MaterialStateProperty
                                  .all<
                                      RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              30.0),
                                ),
                              ),
                            ),
                            child: Text("Ajouter",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                            onPressed: () {
                               Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddContact()));
                            }
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            
            Padding(
  padding: EdgeInsets.only(top: 90,left: 16,right: 16),
  child: TextField(
    decoration: InputDecoration(
      hintText: "Recherche",
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: EdgeInsets.all(8),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: Colors.grey.shade100
          )
      ),
    ),
  ),
),

          Padding(
              padding: EdgeInsets.only(top: 100, left: 15, right: 15),
              child: Stack(children: [
                (userAll.length > 0)
                    ? Padding(
                        padding: EdgeInsets.only(top: 10, left: 5),
                        child: GroupListView(
                          sectionsCount:
                              userAllGrouped!.keys.toList().length,
                          countOfItemInSection: (int section) {
                            return userAllGrouped!.values
                                .toList()[section]
                                .length;
                          },
                          itemBuilder: _itemBuilder,
                          groupHeaderBuilder:
                              (BuildContext context, int section) {
                            var dateFrensh = DateTime.parse(
                                userAllGrouped!.keys
                                    .toList()[section]
                                    .toString());
                            var dateTime = DateTime.parse(userAllGrouped!.keys
                                    .toList()[section]
                                    .toString());
                            var dateTimeAll =
                                dateTime.day + dateTime.month + dateTime.year;
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                child: Container(
                                  // margin: EdgeInsets.only(bottom: 10, top: 10),
                                  // child: Text(
                                  //   (dateTimeAll == dateCurrent)
                                  //       ? "Aujourd'hui"
                                  //       : (dateTimeAll == dateCurrent - 1)
                                  //           ? "Hier"
                                  //           : "${dateFrensh.day}/${dateFrensh.month}/${dateFrensh.year}",
                                  //   style: TextStyle(
                                  //       fontSize: 12.0,
                                  //       fontWeight: FontWeight.normal,
                                  //       color: kPrimaryColor),
                                  // ),
                                )
                                );
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
                              "Pas de Contact",
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
          ],
        ),
              );
    
  }


Widget _itemBuilder(BuildContext context, IndexPath index) {

    UserInterface transaction =
        userAllGrouped!.values.toList()[index.section][index.index];
        MagicMask mask = MagicMask.buildMask('99 999 99 99');
  var formattedString = mask.getMaskedString(transaction.phoneNumber.substring(4));
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.shade200,
            ),
            child: Container(
                width: mediaWidth(context) / 1.07,
                margin: const EdgeInsets.fromLTRB(1.0, 2.0, 7.0, 7.0),
                child: Column(children: <Widget>[
                  Container(
                    width: mediaWidth(context),
                    height: 60,
                    child: ListTile(
                      leading: Container(
                          padding: EdgeInsets.all(10),
                          width: 50,
                          height: 50,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            // border: Border.all(color: Colors.grey, width: 0.5),
                            image: new DecorationImage(
                              image: 
                                   new AssetImage(transaction.userFiles),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: null),
                      title: Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${transaction.firstname} ${transaction.lastname}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                       "${formattedString}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ])),
                      trailing: Container(
                        child: Text(
                          "11:00",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      onTap: () {
                        //print("USER2ID: "+transaction.id.toString());
                        Navigator.push(context, MaterialPageRoute(builder: (context){
          return ChatDetailPage(transaction.id.toString(), transaction.firstname+" "+transaction.lastname, transaction.userFiles);
        }));
                      },
                    ),
                  ),
                ]))));
  }

}