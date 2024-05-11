
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'database.dart';

class Shared {
  static String? username;
  static String? dest = "me_for26";
  static String emailAddressEnd = "@for26.com";
  static String nameExtension = "_for26";
  static String appClicksPass = "152";
  static Databases db = Databases();
  /// reserved chars ['.', '#', '\$', '[', ']', '/', '\\'];

  static int? usernameValidator(String username) {
    List<int> validChars = [
      for (int i = 48; i < 58; i++) i, /// numbers
      for (int i = 65; i < 91; i++) i, /// from A to Z
      for (int i = 97; i < 123; i++) i, /// from a to z
      95 /// underscore
    ];

    for (int i = 0; i < username.length; i++) {
      int ch = username.codeUnitAt(i);
      if (!validChars.contains(ch)) {
        return ch;
      }
    }

    int start = username.codeUnitAt(0);
    if (start > 47 && start < 58) {
      return -1;  /// starts with a digit
    }

    return null;  /// username valid to be used
  }

  static void loading(BuildContext context, String title, Color loadingColor) {
    showDialog(
      context: context,
      builder: (context) =>
        StatefulBuilder(
          builder: (context, setState) {
            Future<bool> _onWillPop() async {
              return false;
            }

            return WillPopScope(
              onWillPop: () => _onWillPop(),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.25,
                      child: Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      )
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      // const SizedBox(width: double.infinity),

                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500
                        ),

                        child: Text(title),
                      ),

                      const SizedBox(width: double.infinity, height: 20),

                      CircularProgressIndicator(color: loadingColor)
                    ],
                  ),
                ],
              )
            );
          }
        )
    );
  }

  static void showToast(String msg, Color bgColor, bool isLong) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: bgColor,
      toastLength: isLong? Toast.LENGTH_LONG : Toast.LENGTH_SHORT
    );
  }
}




/// memory
/// memory title
/// memory content
/// posting date
/// the poster
/// memory date
/// some images
///
///