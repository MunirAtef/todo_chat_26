
// import 'dart:html';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_chat_26/memories.dart';
import 'package:image_picker/image_picker.dart';
import 'shared.dart';


class PostMemory extends StatefulWidget {
  final String address;
  final String name;
  final String image;

  const PostMemory(this.address, this.name, this.image, {Key? key}) : super(key: key);

  @override
  State<PostMemory> createState() => _PostMemoryState();
}

class _PostMemoryState extends State<PostMemory> {
  TextEditingController memoryTitle = TextEditingController();
  TextEditingController memoryDescription = TextEditingController();
  bool isTitleLtr = true;
  bool isDescriptionLtr = true;

  bool pickingDate = false;
  bool pickingImages = false;

  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug"
    , "Sep", "Oct", "Nov", "Dec"];

  // String monthsName = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec";

  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;

  List<String> images = [];

  Color mainColor = Colors.pinkAccent;

  Future<void> postButton() async {
    NavigatorState nav = Navigator.of(context);

    String title = memoryTitle.text.trim();
    String description = memoryDescription.text.trim();
    String date = "$year $month $day";

    DateTime dt = DateTime.now();
    String postingDate = "${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute}";

    String seriesImages = "";
    if (images.isEmpty) {
      seriesImages = "null";
    } else {
      for (String image in images) {
        seriesImages += "${image.split('/').last} ";
      }
      seriesImages = seriesImages.trim();
    }

    if (title.isEmpty) {
      Shared.showToast("No title entered", mainColor, false);
      return;
    }

    DatabaseReference ref =
      FirebaseDatabase.instance.ref('memories/${widget.address}/${Shared.username}').push();

    Memory memory = Memory(
      ref.key!,
      title,
      description,
      date,
      postingDate,
      widget.address,
      seriesImages,
      true
    );

    Shared.loading(context, "Upload images", mainColor);

    /// storage post images
    try {
      for(String imagePath in images) {
        /// Create a Reference to the file
        Reference storageRef = FirebaseStorage.instance
          .ref('memoriesImages/${imagePath.split('/').last}');

        await storageRef.putFile(File(imagePath));
      }
    } on FirebaseException catch(e) {
      print(e);
    }

    nav.pop();

    await ref.set(memory.toJson());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.name),

        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close, color: Colors.white)
          )
        ],
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
                Colors.cyan,
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
            const SizedBox(width: double.infinity, height: 50),

            const Text(
              "Posting a memory",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500
              ),
            ),

            /// title
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)
                ),
              ),
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),

              child: const Center(
                child: Text(
                  "Title",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                )
              ),
            ),

            /// title textField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: memoryTitle,
                onChanged: (newText) {
                  if (newText.isEmpty) {
                    isTitleLtr = true;
                  } else {
                    int firstCh = newText[0].codeUnits[0];
                    isTitleLtr = !(firstCh > 1500 && firstCh < 2000);
                  }

                  setState(() {});
                },
                textDirection: isTitleLtr? TextDirection.ltr: TextDirection.rtl,
                cursorColor: Colors.cyan,
                decoration: InputDecoration(
                  hintText: "Memory title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)
                    ),
                    borderSide: BorderSide(
                      width: 2,
                    ),
                  ),

                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.cyan
                    ),
                  ),
                ),
              ),
            ),


            /// Description
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)
                ),
              ),
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),

              child: const Center(
                child: Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                )
              ),
            ),

            /// Description textField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: memoryDescription,
                minLines: 1,
                maxLines: 10,
                onChanged: (newText) {
                  if (newText.isEmpty) {
                    isDescriptionLtr = true;
                  } else {
                    int firstCh = newText[0].codeUnits[0];
                    isDescriptionLtr = !(firstCh > 1500 && firstCh < 2000);
                  }

                  setState(() {});
                },

                textDirection: isDescriptionLtr? TextDirection.ltr: TextDirection.rtl,
                cursorColor: Colors.cyan,
                decoration: InputDecoration(
                  hintText: "Memory description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)
                    ),
                    borderSide: BorderSide(
                      width: 2,
                    ),
                  ),

                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.cyan
                    ),
                  ),
                ),
              ),
            ),


            /// Date picker
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: pickingDate? const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)
                ): BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: InkWell(
                onTap: () {
                  setState(() {
                    pickingDate = !pickingDate;
                  });
                },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Memory date: ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500
                            ),
                          ),

                          TextSpan(
                            text: "$day ${months[month - 1]} $year",
                            style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ]
                      )
                    ),

                    Icon(
                      pickingDate? Icons.arrow_drop_down: Icons.arrow_drop_up,
                      color: Colors.white,
                      size: 30,
                    )
                  ],
                ),
              ),
            ),

            /// Date picker
            Visibility(
              visible: pickingDate,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  ),
                  border: Border.all(width: 0.7),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoDatePicker(
                  dateOrder: DatePickerDateOrder.dmy,
                  // backgroundColor: Colors.red,
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(year, month, day),
                  // maximumDate: DateTime(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      setState(() {
                        year = newDateTime.year;
                        month = newDateTime.month;
                        day = newDateTime.day;
                      });
                    });
                  },
                  use24hFormat: false,
                  minuteInterval: 1,
                ),
              ),
            ),


            /// images
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: pickingImages? const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20)
                ): BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: InkWell(
                onTap: () {
                  setState(() {
                    pickingImages = !pickingImages;
                  });
                },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Pick images ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),
                            ),

                            TextSpan(
                              text: "(optional)",
                              style: TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ]
                        )
                    ),

                    Icon(
                      pickingImages? Icons.arrow_drop_down: Icons.arrow_drop_up,
                      color: Colors.white,
                      size: 30,
                    )
                  ],
                ),
              ),
            ),

            /// images
            Visibility(
              visible: pickingImages,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  ),
                  border: Border.all(width: 0.7),
                ),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: [
                          for (String imagePath in images)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                maxWidth: 200
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Image.file(File(imagePath)),),

                                  IconButton(
                                    onPressed: () {
                                      images.remove(imagePath);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close)
                                  ),
                                ],
                              ),
                            ),

                          Visibility(
                            visible: images.length < 5,
                            child: InkWell(
                              onTap: () async {
                                final imagePicker = ImagePicker();
                                List<XFile>? pickedImages = await imagePicker.pickMultiImage(maxWidth: 1000, maxHeight: 1000);

                                if (pickedImages.length > 5) {
                                  Shared.showToast("Cannot pick more than 5 images", mainColor, false);
                                  pickedImages = pickedImages.sublist(0, 5);
                                }

                                for (XFile image in pickedImages) {
                                  images.add(image.path);
                                }

                                if (images.length > 5) {
                                  Shared.showToast("Cannot pick more than 5 images", mainColor, false);
                                  images = images.sublist(0, 5);
                                }

                                setState(() {});
                              },

                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: size.width / 4,
                                ),
                              ),
                            ),
                          ),

                          // InkWell(
                          //   onTap: () {
                          //
                          //   },
                          //   child: Icon(
                          //     Icons.photo,
                          //     size: size.width / 3 - 20,
                          //   ),
                          // ),
                          //
                          // InkWell(
                          //   onTap: () {
                          //
                          //   },
                          //   child: Icon(
                          //     Icons.photo,
                          //     size: size.width / 3 - 20,
                          //   ),
                          // ),
                        ]
                      ),
                    ),

                    const Text(
                      "You can pick at most 5 images",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                await postButton();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(mainColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                )
              ),
              child: SizedBox(
                width: size.width - 100,
                height: 25,
                child: const Center(
                  child: Text("Post"),
                )
              )
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// username
///   messages
///     users that send messages
///       messages
///   isTyping
///     users that typing
///   memories
///     users that post memories
///       memories
///
///