
import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'PostMemory.dart';
import 'shared.dart';

class Memories extends StatefulWidget {
  final String address;
  final String name;
  final String image;

  const Memories(this.address, this.name, this.image, {Key? key}) : super(key: key);

  @override
  State<Memories> createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  Color mainColor = Colors.white;
  Color secondColor = Colors.yellow;


  late StreamSubscription<DatabaseEvent> memoriesListener;

  List<Memory> newMemories = [
    Memory(
      "",
      "Day 26",
      "The day that My26 admit to me by her love",
      "17 Feb 2022",
      "14 Oct 2022  1:25 PM",
      "me_for26",
      "null",
      true
    ),

    Memory(
      "",
      "Lola birthday",
      "The day that we get break up for almost 3 months",
      "24 Mar 2022",
      "17 Oct 2022  12:10 AM",
      "me_for26",
      "null",
      false
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DatabaseReference ref =
    FirebaseDatabase.instance.ref('memories/${widget.address}/${Shared.username}');

    memoriesListener = ref.onChildAdded.listen((event) async {
      Object? snapshotValue = event.snapshot.value;
      if (snapshotValue != null) {
        Memory memory = Memory.fromJson(snapshotValue, true);
        memory.dest = widget.address;
        // await getImages(memory.images);
        newMemories.add(memory);

        print("<<${memory.images}>>");
        setState(() {});
        /// save memory to local database
        // await Shared.db;
        // await ref.remove();
      }
    });
  }

  Future<String> getImage(String image) async {
    print("1");
    Reference storageRef = FirebaseStorage.instance.ref('memoriesImages/$image');
    // final islandRef = storageRef;

    print("2");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    print(appDocDir.path);
    final String filePath = "${appDocDir.path}/memoriesImages/$image";
    // final String filePath = "/data/user/0/com.munir_atef.todo_chat_26/files/memoriesImages/$image";
    final File file = File(filePath);

    print("3");

    DownloadTask downloadTask = storageRef.writeToFile(file);

    print("4");

    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          print("Running");
          break;
        case TaskState.paused:
          print("Paused");
          break;
        case TaskState.success:
          print("Success");
          break;
        case TaskState.canceled:
          print("Canceled");
          break;
        case TaskState.error:
          print("Error");
          break;
      }
    });

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await memoriesListener.cancel();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,

          title: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  "Memories",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Times",
                    color: Colors.purple
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Container(
                    height: 42,
                    padding: const EdgeInsets.only(left: 1, right: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[900]!,
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: const Offset(0, 3)
                        )
                      ]
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                        const SizedBox(width: 5),
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Expanded(child: SizedBox()),

                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PostMemory(widget.address, widget.name, widget.image))
                      );
                    },
                    icon: const Icon(Icons.post_add, color: Colors.white)
                  ),

                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.white)
                  ),
                ],
              ),


              // const SizedBox(height: 10),


            ],
          ),

          toolbarHeight: 120,
          // actions: [
          //   IconButton(
          //     onPressed: () async {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(builder: (context) => const PostMemory())
          //       );
          //     },
          //     icon: const Icon(Icons.date_range, color: Colors.white)
          //   ),
          //
          //   IconButton(
          //     onPressed: () async {
          //       Navigator.of(context).pop();
          //     },
          //     icon: const Icon(Icons.close, color: Colors.white)
          //   ),
          // ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: const [
                  0.1,
                  0.4,
                  0.6,
                  0.9,
                ],
                colors: [
                  Colors.black,
                  secondColor,
                  mainColor,
                  Colors.black,
                ],
              ),
            ),
          ),
        ),

        body: SingleChildScrollView(
            child: Column(
              children: [
                for (Memory memory in newMemories)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    width: double.infinity,
                    // height: 500,
                    decoration: BoxDecoration(
                      color: memory.isMe? mainColor : Colors.yellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[700]!,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3)
                        )
                      ]
                    ),

                    child: Column(
                      children: [
                        Text(
                          memory.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        const Divider(thickness: 2),

                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Memory date: ${memory.date}",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Posted in: ${memory.postingDate}",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),

                        const Divider(thickness: 2),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            memory.description,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (memory.images != "null")
                          Container(
                            decoration: BoxDecoration(
                              color: memory.isMe? Colors.grey[300] : Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (String image in memory.images.split(" "))
                                    FutureBuilder(
                                      future: getImage(image),
                                      builder: (context, AsyncSnapshot<String> snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        return SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Image.file(File(snapshot.data!))
                                        );
                                      }
                                    )
                                ],
                              ),
                            ),
                          ),

                        const Divider(thickness: 2),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {

                                });
                              },
                              icon: const Icon(Icons.comment)
                            ),

                            // IconButton(
                            //   onPressed: () {},
                            //   icon: Row(
                            //     children: const [
                            //       Icon(Icons.arrow_downward),
                            //     ],
                            //   )
                            // ),

                            memory.isMe?
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.settings)
                            )
                            : IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite)
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
    );
  }
}



class Memory {
  String id;
  String title;
  String description;
  String date;
  String postingDate;
  String dest;
  String images;
  bool isMe;

  Memory(
    this.id,
    this.title,
    this.description,
    this.date,
    this.postingDate,
    this.dest,
    this.images,
    this.isMe
  );

  Map<String, String> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "date": date,
      "postingDate": postingDate,
      "images": images
    };
  }

  static Memory fromJson(dynamic json, bool fromServer) {
    return Memory(
      json["id"]!,
      json["title"]!,
      json["description"]!,
      json["date"]!,
      json["postingDate"]!,
      fromServer? "" : json["dest"]!,
      json["images"]!,
      fromServer? false : json["isMe"] as int == 1,
    );
  }
}


