

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:todo_chat_26/PostMemory.dart';
import 'package:todo_chat_26/shared.dart';



class ChatRoom extends StatefulWidget {
  final String address;
  final String name;
  final String image;


  const ChatRoom(this.address, this.name, this.image, {Key? key}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  ItemScrollController itemController = ItemScrollController();

  TextEditingController msgFieldController = TextEditingController();
  bool msgFieldRtl = false;

  String? replayToContent;
  String replayToId = "null";
  bool isReplayToMe = false;

  List<Message> newMessages = [];

  List<Map> oldMessages = [];
  int oldMessagesLength = 0;

  late StreamSubscription<DatabaseEvent> messagesListener;
  late StreamSubscription<DatabaseEvent> typingListener;

  late Size size;
  bool typingFlag = false;

  bool isTyping = false;
  int duration = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () async {
      oldMessages = await Shared.db.getMessages(widget.address);
      oldMessagesLength = oldMessages.length;
      setState(() {});
    });

    DatabaseReference ref = FirebaseDatabase.instance.ref('messages/${Shared.username}/${widget.address}');
    DatabaseReference typingRef = FirebaseDatabase.instance.ref('isTyping/${Shared.username}/${widget.address}');

    messagesListener = ref.onChildAdded.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Message msg = Message.fromJson(snapshot.value, true);
        msg.dest = widget.address;
        newMessages.add(msg);

        setState(() {});
        await Shared.db.addMessage(msg);
        await ref.remove();
      }
    });

    typingListener = typingRef.onValue.listen((event) {
      isTyping = true;
      setState(() {});
      duration++;

      int last = duration;
      Future.delayed(const Duration(seconds: 1), () {
        if (last == duration) {
          isTyping = false;
          setState(() {});
        }
      });
    });
  }

  Future<List<Map>> getOldMessages() async {
    List<Map> oldMessages = await Shared.db.getMessages(widget.address);
    oldMessagesLength = oldMessages.length;
    return oldMessages;
  }

  Future scrollToItem() async {
    itemController.scrollTo(index: 5, duration: const Duration(seconds: 1));
  }

  Future<void> sendMessage(Message msg) async {
    final DatabaseReference messagesRef =
    FirebaseDatabase.instance.ref('messages/${widget.address}/${Shared.username}').push();
    msg.id = messagesRef.key.toString();
    await messagesRef.set(msg.toJson());
  }

  Future<Widget> getParentMsg(String id) async {
    try {
      Message msg = Message.fromJson(await Shared.db.getMessageById(id), false);
      return Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.fromLTRB(5, 1, 5, 0),
        decoration: BoxDecoration(
          color: Colors.cyan[500],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10)
          ),
        ),

        child: Column(
          children: [
            Text(
              msg.isMe? "You:": "${widget.name}:",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: msg.isMe? Colors.yellow: Colors.purple
              ),
            ),

            Container(
              constraints: BoxConstraints(
                maxWidth: size.width - 90,
                maxHeight: 50
              ),
              child: Text(
                msg.content,
                overflow: TextOverflow.fade,
                textDirection: isRtl(msg.content)? TextDirection.rtl: TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      );
    } catch(e) {
      return Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.red[500],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10)
          ),
        ),

        child: const Text(
          "Cannot load the message",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white
          ),
        ),
      );
    }
  }

  Widget msgBox(Message msg) {
    return Align(
      alignment: msg.isMe? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (msg.replayTo != "null")
            FutureBuilder<Object>(
                future: getParentMsg(msg.replayTo),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)
                        ),
                      ),
                    );
                  }

                  return snapshot.data;
                }
            ),


          InkWell(
            onTap: () {},

            onDoubleTap: () {
              setState(() {
                replayToContent = msg.content;
                replayToId = msg.id;
                isReplayToMe = msg.isMe;
              });
            },

            child: Container(
              // key: ,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 4),
              constraints: BoxConstraints(
                maxWidth: size.width - 70,
              ),

              decoration: BoxDecoration(
                // gradient: msg.isMe? LinearGradient(
                //   begin: Alignment.topRight,
                //   end: Alignment.bottomLeft,
                //   colors: [
                //     Colors.black,
                //     Colors.blue[300]!,
                //   ],
                // ) : LinearGradient(
                //   begin: Alignment.topRight,
                //   end: Alignment.bottomLeft,
                //   colors: [
                //     Colors.green[300]!,
                //     Colors.yellow[300]!,
                //   ],
                // ),

                  color: msg.isMe? Colors.green[300] : Colors.grey[300],

                  borderRadius: msg.isMe? const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)
                  ) : const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)
                  )
              ),

              child: Column(
                children: [
                  Text(
                    msg.content,
                    textDirection: isRtl(msg.content) ? TextDirection.rtl: TextDirection.ltr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      // color: Colors.white
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    msg.time,
                    // textAlign: msg.isMe? TextAlign.end: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isRtl(String text) {
    int ch = text.trim()[0].codeUnits[0];
    return ch > 1500 && ch < 2000;
  }

  void setTyping() {
    final DatabaseReference typingRef =
    FirebaseDatabase.instance.ref('isTyping/${widget.address}/${Shared.username}');

    typingRef.set(typingFlag);
    typingFlag = !typingFlag;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        await messagesListener.cancel();
        await typingListener.cancel();
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.name),

          toolbarHeight: 70,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PostMemory(widget.address, widget.name, widget.image))
                );
              },
              icon: const Icon(Icons.date_range)
            ),

            IconButton(
              onPressed: () async {
                NavigatorState nav = Navigator.of(context);
                await messagesListener.cancel();
                await typingListener.cancel();
                nav.pop();
              },
              icon: const Icon(Icons.close, color: Colors.white)
            ),
          ],

          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [
                  0.05,
                  0.5,
                  0.65,
                  1,
                ],
                colors: [
                  Colors.black,
                  Colors.green,
                  Colors.purple,
                  Colors.cyan,
                ],
              ),
            ),
          ),
        ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Expanded(
              child: FutureBuilder(
                future: getOldMessages(),
                builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    );
                  }

                  return SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: [
                        const SizedBox(height: 5),

                        for (Map msg in snapshot.data!)
                          msgBox(Message.fromJson(msg, false)),

                        if (newMessages.isNotEmpty)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Text(
                                "New messages",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple
                                ),
                              ),
                            ),
                          ),

                        if (newMessages.isNotEmpty)
                          for (Message msg in newMessages)
                            msgBox(msg),
                      ],
                    ),
                  );

                  // return ScrollablePositionedList.builder(
                  //   itemCount: snapshot.data!.length,
                  //   itemBuilder: (context, index) => msgBox(Message.fromJson(snapshot.data![index], false)),
                  //   itemScrollController: itemController,
                  //   initialScrollIndex: snapshot.data!.length - 20,
                  // );
                },
              )
            ),

            Visibility(
              visible: isTyping,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: LinearProgressIndicator(
                  color: Colors.purple,
                  backgroundColor: Colors.purple[200],
                  minHeight: 10,
                ),
              )
            ),

            Visibility(
                visible: replayToId != "null",
                child: Container(
                  margin: const EdgeInsets.only(top: 5, left: 10, right: 10),
                  padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),

                  decoration: BoxDecoration(
                    color: Colors.cyan[500],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isReplayToMe? "You:": "${widget.name}:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: isReplayToMe? Colors.yellow: Colors.purple
                            ),
                          ),

                          IconButton(
                            // padding: const EdgeInsets.all(0),
                            onPressed: () {
                              setState(() {
                                replayToId = "null";
                              });
                            },
                            icon: const Icon(Icons.close)
                          ),
                        ],
                      ),

                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxHeight: 50
                        ),
                        child: Text(
                          replayToContent.toString(),
                          textDirection: isRtl(replayToContent.toString())? TextDirection.rtl: TextDirection.ltr,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                          ),
                        ),
                      )
                    ],
                  ),
                )
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Expanded(
                    child: TextField(
                      controller: msgFieldController,
                      onChanged: (newText) {
                        setTyping();
                        if (newText.trim().isEmpty) {
                          msgFieldRtl = false;
                        } else {
                          msgFieldRtl = isRtl(newText);
                        }

                        setState(() {});
                      },

                      textInputAction: TextInputAction.newline,
                      maxLines: 6,
                      minLines: 1,
                      textDirection: msgFieldRtl? TextDirection.rtl : TextDirection.ltr,
                      cursorColor: Colors.purple,

                      style: const TextStyle(
                        fontWeight: FontWeight.w500
                      ),

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            width: 2
                          )
                        ),
                        fillColor: Colors.grey[300],
                        filled: true,
                        hintText: "Write a message..",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ),
                  ),

                  if (msgFieldController.text.trim().isEmpty)
                    IconButton(
                      onPressed: () {
                        scrollToItem();
                      },
                      icon: const Icon(Icons.attach_file, color: Colors.red),
                    )
                  else
                    IconButton(
                      onPressed: () async {
                        DateTime dt = DateTime.now();
                        String date = "${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute}";
                        Message tempMsg = Message("", replayToId, 0, msgFieldController.text, true, date, widget.address);

                        await sendMessage(tempMsg);
                        newMessages.add(tempMsg);
                        await Shared.db.addMessage(tempMsg);
                        msgFieldController.clear();
                        replayToId = "null";

                        setState(() {});
                      },

                      icon: const Icon(Icons.send, color: Colors.purple),
                    )
                ],
              ),
            ),
          ],
        ),

        drawer: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.yellow,
                Colors.red,
                Colors.green
              ],
            )
          ),
        ),
      ),
    );
  }
}



class Message {
  String id;
  String replayTo;
  int type;  /// 0 => TEXT, 1 => LINK, 2 => IMAGE
  String content;
  bool isMe;
  String time;
  String dest;

  Message(
    this.id,
    this.replayTo,
    this.type,
    this.content,
    this.isMe,
    this.time,
    this.dest
  );

  toJson() {
    return {
      'id': id,
      'replayTo': replayTo,
      'type': type,
      'content': content,
      'time': time
    };
  }


  factory Message.fromJson(dynamic json, bool fromServer) {
    return Message(
      json['id'] as String,
      json['replayTo'] as String,
      json['type'] as int,
      json['content'] as String,
      fromServer? false: json['isMe'] == 1? true : false,
      json['time'] as String,
      "",
    );
  }

  /// id TEXT PRIMARY KEY,
  /// type INTEGER,
  /// content TEXT,
  /// time TEXT,
  /// replayTo TEXT,
  /// dest TEXT
}


