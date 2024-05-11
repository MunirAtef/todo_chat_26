// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_chat_26/Contacts.dart';
import 'package:todo_chat_26/memories.dart';
import 'package:todo_chat_26/PostMemory.dart';
import 'package:todo_chat_26/shared.dart';

import 'Login.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
     const MaterialApp(
      title: "For 26",
      home: Splash(),
      debugShowCheckedModeBanner: false
    ),
  );
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _secretClicks = "";
  // TextEditingController destController = TextEditingController();

  // var childAddedListener;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //
  //   // FirebaseDatabase.instance.ref('messages/${Shared.username}/${Shared.dest}').onChildAdded.listen((data) {
  //   //   DataSnapshot snapshot = data.snapshot;
  //   //   print(snapshot.value);
  //   // } );
  //
  //   // FirebaseDatabase database;
  //   // database = FirebaseDatabase.instance;
  //   // database.setPersistenceEnabled(true);
  //   // // database.setPersistenceCacheSizeBytes(10000000);
  //   //
  //   // DatabaseReference reference = database.ref().child('Sweets');
  //   // var childAddedListener = reference.onChildAdded.listen();
  //   // // StreamSubscription<DatabaseEvent> childChangedListener = reference.onChildChanged.listen(_onEntryChangedShop);
  //   //
  //   // super.initState();
  //
  //
  //   DatabaseReference ref = FirebaseDatabase.instance.ref('messages/${Shared.username}/${Shared.dest}');
  //
  //   ref.onValue.listen((event) async {
  //     DataSnapshot snapshot = event.snapshot;
  //     if (snapshot.value != null) {
  //       for (DataSnapshot i in snapshot.children) {
  //         Message msg = Message.fromJson(i.value);
  //         messages.add(msg);
  //         setState(() {});
  //         print("<<${msg.message}  =>  ${i.key}>>");
  //       }
  //
  //       await ref.remove();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final User? user = Auth().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("For 26"),
        toolbarHeight: 80,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity, height: 30),

          Text(
            user != null? "Current user: ${user.email!.split("@").first}"
              : "No user",

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),



          const Expanded(child: SizedBox()),

          ElevatedButton(
            onPressed: () {
              Shared.loading(context, "Loading...", Colors.yellow);
              Future.delayed(const Duration(seconds: 5), () {Navigator.of(context).pop();} );
            },
            child: const SizedBox(width: 250, child: Center(child: Text("Loading page")))
          ),


          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Memories("me_for26", "Munir Atef", "null"))
                );
              },
              child: const SizedBox(width: 250, child: Center(child: Text("Memories")))
          ),


          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PostMemory("me_for26", "Munir Atef", "null"))
                );
              },
              child: const SizedBox(width: 250, child: Center(child: Text("Post memory")))
          ),


          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Contacts())
              );
              // String? token = await FirebaseMessaging.instance.getToken();
              // print(token);
            },
            child: const SizedBox(width: 250, child: Center(child: Text("Contacts")))
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup())
              );
            },
            child: const SizedBox(width: 250, child: Center(child: Text("Sign up")))
          ),

          OutlinedButton(
            onPressed: () async {
              try {
                await Auth().signOut();
                Shared.username = null;
              } on FirebaseAuthException catch(e) {
                Fluttertoast.showToast(msg: e.code.toString());
              }

              setState(() {});
            },

            child: const SizedBox(width: 250, child: Center(child: Text("Sign out")))
          ),

          const SizedBox(height: 30),
        ],
      ),

      drawer: SizedBox(
        width: size.width * 2/3,
        child: Column(
          children: [
            const Expanded(child: SizedBox()),

            const Divider(height: 1),

            InkWell(
              onLongPress: () {
                _secretClicks = "";
              },
              onDoubleTap: () {
                // if (_secretClicks == Shared.appClicksPass) {
                //   Navigator.of(context).push(
                //     MaterialPageRoute(builder: (context) => const ChatRoom())
                //   );
                // }
              },

              child: SizedBox(
                width: size.width,
                height: size.width / 3,
              ),
            ),

            const Divider(height: 1),

            Row(
              children: [
                InkWell(
                  onTap: () {
                    _secretClicks += "1";
                  },
                  onLongPress: () {
                    _secretClicks += "2";
                  },
                  onDoubleTap: () {
                    _secretClicks += "3";
                  },
                  child: SizedBox(
                    width: size.width / 3,
                    height: size.width / 3,
                  ),
                ),

                InkWell(
                  onTap: () {
                    _secretClicks += "4";
                  },
                  onLongPress: () {
                    _secretClicks += "5";
                  },
                  onDoubleTap: () {
                    _secretClicks += "6";
                  },
                  child: SizedBox(
                    width: size.width / 3,
                    height: size.width / 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final User? user = Auth().currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (Auth().currentUser == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Signup())
        );
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage())
        );

        Shared.username = Auth().currentUser!.email!.split("@").first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(width: double.infinity),

          Text(
            "WELCOME TO TODO CHAT",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}



