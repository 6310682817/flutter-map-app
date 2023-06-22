import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';

enum _MenuOptions {
  Logout,
  CloseApplication,
}

class Menu extends StatelessWidget {
  const Menu({required this.controller, super.key});

  final WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.Logout:
            Navigator.pop(context);
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ));
            break;
          case _MenuOptions.CloseApplication:
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.Logout,
          child: Text('Logout'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.CloseApplication,
          child: Text('Close Live Location'),
        ),
      ],
    );
  }
}
