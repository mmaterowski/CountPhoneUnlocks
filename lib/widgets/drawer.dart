import 'package:flutter/material.dart';
import 'package:rHabbit/widgets/routes.dart';

class RHabbitDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          _createDrawerItem(
              text: "About",
              icon: Icons.info,
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.about)),
          _createDrawerItem(
              text: "Home",
              icon: Icons.calendar_today,
              onTap: () =>
                  Navigator.pushReplacementNamed(context, Routes.home)),
          _createDrawerItem(text: "Item3", icon: Icons.add_to_home_screen)
        ],
      ),
    );
  }
}

Widget _createDrawerItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(leading: new Icon(icon), title: Text(text), onTap: onTap);
}
