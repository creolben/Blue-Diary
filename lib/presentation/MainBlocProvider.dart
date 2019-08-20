import 'package:flutter/material.dart';

import 'MainBloc.dart';

class MainBlocProvider extends InheritedWidget {
  final MainBloc bloc = MainBloc();

  MainBlocProvider({Key key, Widget child}): super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static MainBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(MainBlocProvider) as MainBlocProvider).bloc;
  }
}