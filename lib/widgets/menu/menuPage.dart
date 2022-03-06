import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../appState.dart';
import '../alarmClock/alarmClockPage.dart';
import '../layout.dart';
import '../settingsPage.dart';
import 'menuItem.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(30),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: [
          MenuItem(
            name: 'Go Back',
            icon: FluentIcons.back,
            onPressed: () => Navigator.pop(context),
          ),
          GestureDetector(
            onPanDown: (_) => windowManager.startDragging(),
            child: MenuItem(
              name: 'Move Watch',
              icon: FluentIcons.move,
            ),
          ),
          MenuItem(
            name: 'Close Watch',
            icon: FluentIcons.cancel,
            color: Colors.red,
            onPressed: () => exit(0),
          ),
          MenuItem(
            name: 'Alarm Clock',
            icon: FluentIcons.alarm_clock,
            onPressed: () => Navigator.push(context,
                FluentPageRoute(builder: (context) => AlarmClockPage())),
          ),
          MenuItem(
            name: 'Settings',
            icon: FluentIcons.settings,
            onPressed: () => Navigator.push(
                context, FluentPageRoute(builder: (context) => SettingsPage())),
          ),
        ],
      ),
    );
  }
}
