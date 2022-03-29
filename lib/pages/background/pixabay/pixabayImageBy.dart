import 'package:fluent_ui/fluent_ui.dart';
import 'package:smart_watch_widget/pages/background/pixabay/pixabayImageResult.dart';
import 'package:url_launcher/url_launcher.dart';

class PixabayImageBy extends StatelessWidget {
  final PixabayImage image;

  const PixabayImageBy({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 2, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Text(
              'Image by ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                  style:
                      ButtonStyle(padding: ButtonState.all(EdgeInsets.all(0))),
                  child: Text(image.user ?? ''),
                  onPressed: () => launch(
                      'https://pixabay.com/users/${image.user}-${image.user_id}')),
            ),
            Text(
              ' from ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                  style:
                      ButtonStyle(padding: ButtonState.all(EdgeInsets.all(0))),
                  child: Text('Pixabay'),
                  onPressed: () => launch('https://pixabay.com/')),
            ),
          ],
        ),
      ),
    );
  }
}