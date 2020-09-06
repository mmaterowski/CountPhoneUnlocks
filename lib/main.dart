import 'package:flutter/material.dart';
import 'package:rHabbit/styles/theme.dart';
import 'package:splashscreen/splashscreen.dart';
import 'MyHomePage.dart';

void main() {
  runApp(new MaterialApp(
    title: 'rHabbit',
    theme: ShrineTheme.buildTheme(),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 3,
        navigateAfterSeconds: new MyHomePage(),
        title:
            new Text('rHabbit', style: Theme.of(context).textTheme.headline3),
        image: Image.asset('assets/images/rHabbit-pink.png'),
        backgroundColor: Theme.of(context).bottomAppBarColor,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        gradientBackground: new LinearGradient(
            begin: Alignment.bottomLeft,
            end:
                Alignment.topLeft, // 10% of the width, so there are ten blinds.
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.onBackground
            ], // whitish to gray
            tileMode:
                TileMode.repeated), // repeats the gradient over the canvas)
        loadingText: new Text("We're getting things ready for You",
            style: Theme.of(context).textTheme.subtitle2),
        loaderColor: Theme.of(context).accentColor);
  }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'rHabbit',
//       theme: _kShrineTheme,
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

}
