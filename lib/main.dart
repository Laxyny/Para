import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Para/components/life_cycle_event_handler.dart';
import 'package:Para/landing/landing_page.dart';
import 'package:Para/screens/mainscreen.dart';
import 'package:Para/services/user_service.dart';
import 'package:Para/utils/config.dart';
import 'package:Para/utils/constants.dart';
import 'package:Para/utils/providers.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

void main() async {
  DiscordRPC.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initFirebase();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: notifier.dark ? Constants.darkTheme : Constants.lightTheme,
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                if (snapshot.hasData) {
                  return TabScreen();
                } else
                  return Landing();
              },
            ),
          );
        },
      ),
    );
  }
}
