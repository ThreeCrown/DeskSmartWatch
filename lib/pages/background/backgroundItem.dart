import 'package:fluent_ui/fluent_ui.dart';
import 'package:smart_watch_widget/utils/animations.dart';

class BackgroundItem extends StatelessWidget {
  final String name;
  final Widget background;
  final bool isSelected;
  final void Function() onPressed;

  const BackgroundItem({
    Key? key,
    required this.name,
    required this.background,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      style: ButtonStyle(
        padding: ButtonState.all(EdgeInsets.zero),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            child: background,
          ),
          Center(child: Text(name)),
          Positioned(
            top: 5,
            right: 5,
            child: AnimatedSlideFade(
              child: isSelected
                  ? InfoBadge(
                      source: Icon(FluentIcons.accept),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
