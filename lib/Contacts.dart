
import 'package:flutter/material.dart';
import 'chat_room.dart';
import 'shared.dart';


class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Map> connections = [];
  Color focusedColor = Colors.purple;
  Color enabledColor = Colors.black;

  Color textFieldFillColor = const Color.fromRGBO(200, 200, 200, 0.5);

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  FocusNode usernameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();

  bool isPasswordEntered = false;
  bool isPasswordHidden = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () async {
      connections = await Shared.db.getConnections();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.purple,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("For 26 - Contacts"),
        toolbarHeight: 70,

        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddContact())
              );
              connections = await Shared.db.getConnections();
              setState(() {});
            },
            icon: const Icon(Icons.add)
          ),
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
                Colors.red,
                focusedColor,
                Colors.black,
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (Map contact in connections)
              connectionCard(contact),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  connectionCard(Map connection) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChatRoom(
            connection["address"],
            connection["name"],
            connection["image"]
          ))
        );
      },

      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              child: Icon(Icons.account_circle, size: 60)
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                connection["name"],
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 5),

              Text(
                connection["address"],
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}



class AddContact extends StatefulWidget {
  const AddContact({Key? key}) : super(key: key);

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  Color focusedColor = Colors.purple;
  Color enabledColor = Colors.black;

  Color textFieldFillColor = const Color.fromRGBO(200, 200, 200, 0.5);

  final TextEditingController name = TextEditingController();
  final TextEditingController username = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();


  Color textFiledColor = Colors.grey[300]!;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.purple,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("For 26 - Add contact"),
        toolbarHeight: 70,

        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close)
          ),
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
                Colors.red,
                focusedColor,
                Colors.black,
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
                clipBehavior: Clip.none,

                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 50),
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: focusedColor,
                        child: const Icon(Icons.person, size: 150, color: Colors.white),
                      )
                  ),

                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[50],
                      radius: 24,
                      child: IconButton(
                        icon: Icon(Icons.add_a_photo, color: Colors.grey[600]),
                        color: Colors.grey[800],
                        iconSize: 30,
                        onPressed: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                              title: const Text("Pick From"),
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.image, color: Colors.blue),
                                  title: const Text("Gallery"),
                                  onTap: () async {
                                    // uploadImageGallery();
                                    Navigator.of(context).pop();
                                  },
                                ),

                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                                  title: const Text("Camera"),
                                  onTap: () async {
                                    // uploadImageCamera();
                                    Navigator.of(context).pop();
                                  },
                                ),

                                // Visibility(child: const Divider(thickness: 2), visible: clientImage.path != "null"),

                                Visibility(
                                  child: ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.blue),
                                    title: const Text("Delete"),
                                    onTap: () async {
                                      setState(() {
                                        // clientImage = File("null");
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  // visible: clientImage.path != "null",
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]
            ),

            const SizedBox(width: double.infinity, height: 50),

            SizedBox(
              width: size.width - 60,
              child: TextField(
                controller: name,
                focusNode: nameFocus,
                onChanged: (newText) {
                  // if (newText.isEmpty) {
                  //   setState(() { usernameInvalidChar = null; });
                  //   return;
                  // }
                  // setState(() {
                  //   usernameInvalidChar = Shared.usernameValidator(newText.trim());
                  // });
                },

                textInputAction: TextInputAction.done,
                maxLines: 1,
                cursorColor: focusedColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                        width: 2,
                        color: focusedColor
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2, color: enabledColor),
                  ),

                  prefixIcon: Icon(
                      Icons.person,
                      color: nameFocus.hasFocus? focusedColor : enabledColor
                  ),

                  fillColor: textFieldFillColor,
                  filled: true,
                  hintText: "Name",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: size.width - 60,
              child: TextField(
                controller: username,
                focusNode: usernameFocus,
                onChanged: (newText) {
                  // if (newText.isEmpty) {
                  //   setState(() { usernameInvalidChar = null; });
                  //   return;
                  // }
                  // setState(() {
                  //   usernameInvalidChar = Shared.usernameValidator(newText.trim());
                  // });
                },

                textInputAction: TextInputAction.done,
                maxLines: 1,
                cursorColor: focusedColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                        width: 2,
                        color: focusedColor
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2, color: enabledColor),
                  ),

                  prefixIcon: Icon(
                      Icons.account_circle,
                      color: usernameFocus.hasFocus? focusedColor : enabledColor
                  ),

                  fillColor: textFieldFillColor,
                  filled: true,
                  hintText: "Username",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            const SizedBox(height: 30),


            SizedBox(
              width: size.width - 80,
              child: ElevatedButton(
                onPressed: () async {
                  var nav = Navigator.of(context);
                  Shared.loading(context, "Adding contact...", focusedColor);

                  await Shared.db.addConnection(name.text.trim(), username.text.trim(), "null");

                  nav.pop();
                  nav.pop();
                },

                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(focusedColor)
                ),
                child: const Center(child: Text("Add")),
              ),
            ),

            // TextButton(
            //     onPressed: () {
            //       // Navigator.pushReplacement(
            //       //     context,
            //       //     MaterialPageRoute(builder: (context) => const SignIn())
            //       // );
            //       // signIn();
            //     },
            //
            //     style: ButtonStyle(
            //         foregroundColor: MaterialStateProperty.all(focusedColor)
            //     ),
            //     child: const Text("Already have an account? Sign in")
            // ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // connectionCard(Map connection) {
  //   return InkWell(
  //     onTap: () {
  //       dest = connection["address"];
  //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ChatRoom()));
  //     },
  //
  //     child: Row(
  //       children: [
  //         const CircleAvatar(
  //             radius: 40,
  //             child: Icon(Icons.account_circle, size: 80,)
  //         ),
  //
  //         Column(
  //           children: [
  //             Text(
  //               connection["name"],
  //               style: const TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold
  //               ),
  //             ),
  //
  //             Text(
  //               connection["address"],
  //               style: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.red
  //               ),
  //             )
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }
}
