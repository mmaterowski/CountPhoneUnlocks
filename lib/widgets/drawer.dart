import 'package:flutter/material.dart';

class RHabbitDrawer {
  static Drawer build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Drawer Header',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            title: Text('Item 1', style: Theme.of(context).textTheme.headline6),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(
              'Item 2',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
