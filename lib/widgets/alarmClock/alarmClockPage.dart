import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:smart_watch_widget/widgets/alarmClock/alarmClockState.dart';

import '../layout.dart';
import '../menu/menuItem.dart';
import 'alarmClockFrom.dart';
import 'alarmClockItem.dart';

class AlarmClockPage extends StatelessWidget {
  const AlarmClockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      MenuItem(
        title: 'Back',
        icon: FluentIcons.back,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      Container(height: 10),
    ];

    context.watch<AlarmClockState>().alarms.forEach((alarm) {
      children.addAll([AlarmClockItem(alarm: alarm), Container(height: 10)]);
    });

    children.add(
      MenuItem(
        title: 'New Alarm',
        icon: FluentIcons.add,
        onPressed: () => Navigator.push(
            context,
            FluentPageRoute(
                builder: (context) => AlarmClockFrom(alarm: Alarm()))),
      ),
    );

    return Layout(
      child: ListView(
        padding: const EdgeInsets.all(30),
        children: children,
      ),
    );
  }
}