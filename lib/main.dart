import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'MyHomePage.dart';
import 'colors.dart';

void main() {
  runApp(new MaterialApp(
    title: 'rHabbit',
    theme: _kShrineTheme,
    home: MyApp(),
  ));
}

final ThemeData _kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: kShrineBrown900,
    primaryColor: kShrinePink100,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: kShrinePink100,
      colorScheme: base.colorScheme.copyWith(
        secondary: kShrineBrown900,
      ),
    ),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent,
    ),
    scaffoldBackgroundColor: kShrineBackgroundWhite,
    cardColor: kShrineBackgroundWhite,
    textSelectionColor: kShrinePink100,
    errorColor: kShrineErrorRed,
    textTheme: _buildShrineTextTheme(base.textTheme),
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
    primaryIconTheme: base.iconTheme.copyWith(color: kShrineBrown900),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        headline5: base.headline5.copyWith(
          fontWeight: FontWeight.w500,
        ),
        headline6: base.headline6.copyWith(fontSize: 18.0),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
        bodyText1: base.bodyText1.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: kShrineBrown900,
        bodyColor: kShrineBrown900,
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 3,
        navigateAfterSeconds: new MyHomePage(title: 'Flutter Demo Home Page'),
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
        loaderColor: _kShrineTheme.accentColor);
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
