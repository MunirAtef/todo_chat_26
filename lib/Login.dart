
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_chat_26/shared.dart';
import 'package:todo_chat_26/main.dart';


/// invalid-email
/// user-not-found
/// wrong-password
/// network-request-failed
/// email-already-in-use
/// too-many-requests

Map<String, String> exceptions = {
  "invalid-email": "Invalid username",
  "user-not-found": "Wrong username or password",
  "wrong-password": "Wrong username or password",
  "email-already-in-use": "Username taken",
  "network-request-failed": "Connection error",
  "too-many-requests": "Too many requests.. try later"
};


class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  int? usernameInvalidChar;

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  FocusNode usernameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();

  bool isPasswordEntered = false;
  bool isPasswordHidden = true;

  Color focusedColor = Colors.green;
  Color enabledColor = Colors.black;
  Color textFieldFillColor = const Color.fromRGBO(200, 200, 200, 0.5);

  void showToast(String msg, bool isLong) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: focusedColor,
      toastLength: isLong? Toast.LENGTH_LONG : Toast.LENGTH_SHORT
    );
  }

  Future<bool> signupButton() async {
    String name = username.text.trim();
    String pass = password.text;
    String confPass = confirmPassword.text;

    if (usernameInvalidChar != null) {
      showToast("Invalid username", false);
      return false;
    }

    if (name.isEmpty || pass.isEmpty || confPass.isEmpty) {
      showToast("Empty fields found", false);
      return false;
    }

    if (!name.endsWith(Shared.nameExtension)) {
      showToast("Username should ends with ${Shared.nameExtension}", true);
      return false;
    }

    if (pass != confPass) {
      showToast("Two passwords not matching", false);
      return false;
    }

    try {
      await Auth().createNewUser(name + Shared.emailAddressEnd, password.text);
      Shared.username = name;

      return true;
    } on FirebaseAuthException catch(e) {
      String? msg = exceptions.containsKey(e.code.toString())?
      exceptions[e.code.toString()]: e.code.toString();

      showToast(msg.toString(), true);

      return false;
    }
  }

  Widget usernameErrorHint() {
    if (usernameInvalidChar == null) return const Text("");

    if (usernameInvalidChar == -1) {
      return const Text(
        "Can't start with a digit",
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }
    else if (usernameInvalidChar == 32 || usernameInvalidChar == 9) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Can't use white spaces",
              style: TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(width: 10),

            InkWell(
              onTap: () {},
              child: const Text(
                "More info",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ]
      );
    }
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Invalid Character <<",
            style: TextStyle(
              color: Colors.red,
            ),
          ),

          Text(
            String.fromCharCode(usernameInvalidChar!),
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),

          const Text(
            ">>",
            style: TextStyle(
              color: Colors.red,
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: () {},
            child: const Text(
              "More info",
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: Colors.purple,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("For 26 - Sign up"),
        toolbarHeight: 70,

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
                controller: username,
                focusNode: usernameFocus,
                onChanged: (newText) {
                  if (newText.isEmpty) {
                    setState(() { usernameInvalidChar = null; });
                    return;
                  }
                  setState(() {
                    usernameInvalidChar = Shared.usernameValidator(newText.trim());
                  });
                },

                textInputAction: TextInputAction.done,
                maxLines: 1,
                cursorColor: focusedColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      width: 2,
                      color: usernameInvalidChar == null?
                        focusedColor : Colors.red
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2, color: enabledColor),
                  ),

                  prefixIcon: Icon(
                    Icons.account_circle,
                    color: usernameFocus.hasFocus?
                      usernameInvalidChar == null? focusedColor
                        : Colors.red : enabledColor
                  ),

                  fillColor: textFieldFillColor,
                  filled: true,
                  hintText: "Username",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            usernameErrorHint(),

            const SizedBox(height: 20),

            SizedBox(
              width: size.width - 60,
              child: TextField(
                controller: password,
                focusNode: passwordFocus,
                onChanged: (newText) {
                  setState(() {
                    confirmPassword.clear();
                    isPasswordEntered = newText.length > 5;
                  });
                },

                obscureText: isPasswordHidden,
                enableSuggestions: false,
                autocorrect: false,

                textInputAction: TextInputAction.done,
                maxLines: 1,
                cursorColor: focusedColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2,color: focusedColor),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2,color: enabledColor),
                  ),

                  prefixIcon: Icon(
                    Icons.password,
                    color: passwordFocus.hasFocus? focusedColor : enabledColor
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },

                    icon: Icon(
                        isPasswordHidden? Icons.visibility : Icons.visibility_off,
                        color: passwordFocus.hasFocus? focusedColor : enabledColor
                    ),
                  ),


                  fillColor: textFieldFillColor,
                  filled: true,
                  hintText: "Password",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: size.width - 60,
              child: TextField(
                controller: confirmPassword,
                focusNode: confirmFocus,
                onChanged: (newText) {},

                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                enabled: isPasswordEntered,

                textInputAction: TextInputAction.done,
                maxLines: 1,
                cursorColor: focusedColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2, color: focusedColor),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2, color: enabledColor),
                  ),

                  disabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 1, color: Colors.grey[400]!),
                  ),

                  prefixIcon: Icon(
                    Icons.password,
                    color: confirmFocus.hasFocus?
                      focusedColor : isPasswordEntered? enabledColor : Colors.grey[400]
                  ),

                  fillColor: textFieldFillColor,
                  filled: true,
                  hintText: "Confirm Password",
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
                  Shared.loading(context, "Signing up", focusedColor);

                  bool isSignedUp = await signupButton();
                  nav.pop();

                  if (isSignedUp) {
                    nav.pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage())
                    );
                  }
                },
                
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(focusedColor)
                ),
                child: const Center(child: Text("Sign up")),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn())
                );
                // signIn();
              },

              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(focusedColor)
              ),
              child: const Text("Already have an account? Sign in")
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}



class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController password = TextEditingController();
  final TextEditingController username = TextEditingController();
  int? usernameInvalidChar;

  bool isPasswordHidden = true;

  FocusNode usernameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  Color focusedColor = Colors.cyan;
  Color enabledColor = Colors.black;

  void showToast(String msg, bool isLong) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: focusedColor,
        toastLength: isLong? Toast.LENGTH_LONG : Toast.LENGTH_SHORT
    );
  }

  Future<bool> signInButton() async {
    String name = username.text.trim();
    String pass = password.text;

    if (name.isEmpty || pass.isEmpty) {
      showToast("Empty fields found!", false);
      return false;
    }

    if (!name.endsWith(Shared.nameExtension)) {
      showToast("Invalid username", false);
      return false;
    }

    try {
      await Auth().signInWithEmail(username.text.trim() + Shared.emailAddressEnd, password.text);
      Shared.username = name;

      return true;
    } on FirebaseAuthException catch(e) {
      String? msg = exceptions.containsKey(e.code.toString())?
      exceptions[e.code.toString()]: e.code.toString();

      showToast(msg.toString(), true);

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("For 26 - Sign in"),
        toolbarHeight: 70,

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
            const SizedBox(width: double.infinity, height: 50),

            SizedBox(
              width: size.width - 60,
              child: TextField(
                focusNode: usernameFocus,
                controller: username,

                onChanged: (newText) {
                  if (newText.isEmpty) {
                    setState(() {
                      usernameInvalidChar = null;
                    });
                    return;
                  }
                  setState(() {
                    usernameInvalidChar = Shared.usernameValidator(newText.trim());
                  });
                },

                textInputAction: TextInputAction.done,
                maxLines: 1,
                textDirection: TextDirection.ltr,
                cursorColor: focusedColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      width: 2,
                      color: usernameInvalidChar == null? focusedColor
                        : Colors.red
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2, color: enabledColor),
                  ),

                  // disabledBorder: const OutlineInputBorder(
                  //   borderRadius: BorderRadius.all(Radius.circular(20)),
                  //   borderSide: BorderSide(width: 2,color: Colors.orange),
                  // ),
                  //
                  // errorBorder: const OutlineInputBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     borderSide: BorderSide(width: 2,color: Colors.black)
                  // ),
                  //
                  // focusedErrorBorder: const OutlineInputBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(4)),
                  //     borderSide: BorderSide(width: 2,color: Colors.yellowAccent)
                  // ),

                  prefixIcon: Icon(
                    Icons.account_circle,
                    color: usernameFocus.hasFocus?
                    usernameInvalidChar == null? focusedColor : Colors.red
                        : enabledColor
                  ),

                  fillColor: Colors.grey[300],
                  filled: true,
                  hintText: "Username",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: size.width - 60,
              child: TextField(
                controller: password,
                focusNode: passwordFocus,

                obscureText: isPasswordHidden,
                enableSuggestions: false,
                autocorrect: false,

                textInputAction: TextInputAction.done,
                maxLines: 1,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2,color: focusedColor),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 2,color: enabledColor),
                  ),


                  prefixIcon: Icon(
                    Icons.password,
                    color: passwordFocus.hasFocus? focusedColor : enabledColor
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },

                    icon: Icon(
                      isPasswordHidden? Icons.visibility : Icons.visibility_off,
                      color: passwordFocus.hasFocus? focusedColor : enabledColor
                    ),
                  ),

                  fillColor: Colors.grey[300],
                  filled: true,
                  hintText: "Password",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
              ),
            ),

            const SizedBox(height: 30),


            SizedBox(
              width: size.width - 80,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(focusedColor)
                ),

                onPressed: () async {
                  NavigatorState nav = Navigator.of(context);
                  Shared.loading(context, "Singing in", focusedColor);

                  bool isSignedIn = await signInButton();
                  nav.pop();

                  if (isSignedIn) {
                    nav.pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage())
                    );
                  }
                },

                child: const Center(child: Text("Sign in")),
              ),
            ),

            TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Signup())
                  );
                },
                style: ButtonStyle(
                  // backgroundColor: MaterialStateProperty.all(focusedColor),
                  foregroundColor: MaterialStateProperty.all(focusedColor)
                ),
                child: const Text("Don't have an account? Sign up")
            ),
          ],
        ),
      ),
    );
  }
}





class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createNewUser(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}




class UserSecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _usernameKey = 'username';
  static const _passwordKey = 'password';

  static Future setUsername(String username) async =>
      await _storage.write(key: _usernameKey, value: username);

  static Future<String?> getUsername() async =>
    await _storage.read(key: _usernameKey);

  static Future setPassword(String password) async =>
      await _storage.write(key: _passwordKey, value: password);

  static Future<String?> getPassword() async =>
      await _storage.read(key: _passwordKey);
}

