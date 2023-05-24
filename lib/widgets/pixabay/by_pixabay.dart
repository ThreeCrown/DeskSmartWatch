import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ByPixabay extends StatelessWidget {
  const ByPixabay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 2, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Text(
              'Images from ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: HyperlinkButton(
                  style: ButtonStyle(
                      padding: ButtonState.all(const EdgeInsets.all(0))),
                  child: const Text('Pixabay'),
                  onPressed: () => launchUrlString('https://pixabay.com/')),
            ),
          ],
        ),
      ),
    );
  }
}
