import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../appState.dart';
import 'layout.dart';
import 'menu/menuItem.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          MenuItem(
            name: 'Back',
            icon: FluentIcons.back,
            onPressed: () {
              Provider.of<AppState>(context, listen: false).setMenuOpen(false);
              Navigator.pop(context);
            },
          ),
          StatefulBuilder(
            builder: ((context, setState) {
              bool _checked = false;

              return ToggleSwitch(
                checked: _checked,
                onChanged: (v) => setState(() => _checked = v),
                content: Text(_checked ? 'On' : 'Off'),
              );
            }),
          ),
        ],
      ),
    );
  }
}