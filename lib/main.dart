import 'package:codelab_flutter_at_octo/activity_repository.dart';
import 'package:codelab_flutter_at_octo/basic_activity_page.dart';
import 'package:codelab_flutter_at_octo/codelab_middleware.dart';
import 'package:codelab_flutter_at_octo/codelab_reducer.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final client = Client();
    final repository = ActivityRepository(client);
    final store = Store<CodelabState>(
      reducer,
      initialState: const CodelabState(
        status: CodelabStatus.EMPTY,
        activity: null,
      ),
      middleware: [
        CodelabMiddleware(repository),
      ],
    );
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const BasicActivityPage(),
      ),
    );
  }
}
