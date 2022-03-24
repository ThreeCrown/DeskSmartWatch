import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:isolate';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:schedulers/schedulers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_watch_widget/pages/alarmClock/alarmScreenPage.dart';
import 'package:smart_watch_widget/utils/animations.dart';
import 'package:smart_watch_widget/models/alarm.dart';
import 'package:smart_watch_widget/pages/alarmClock/alarmClockItem.dart';
import 'package:smart_watch_widget/utils/generalScope.dart';
import 'package:smart_watch_widget/widgets/listItemPadding.dart';
import 'package:win32/win32.dart';
import 'package:win_toast/win_toast.dart';
import 'package:window_manager/window_manager.dart';

const alarmsPrefsKey = 'alarms';
const windowsMediaPath = 'C:/Windows/Media';

class AlarmClockState extends ChangeNotifier {
  final SharedPreferences _prefs;
  final alarmsAnimatedListKey = GlobalKey<AnimatedListState>();

  List<Alarm> _alarms = [];
  List<Alarm> get alarms => _alarms;
  TimeScheduler? scheduler;

  AlarmClockState(this._prefs) {
    _getAlarms();
    _scheduleAlarms();
  }

  void _getAlarms() {
    final alarmString = _prefs.getString(alarmsPrefsKey);
    if (alarmString != null) {
      _alarms = (jsonDecode(alarmString) as List)
          .map((e) => Alarm.fromJson(e))
          .toList()
          .cast<Alarm>();

      notifyListeners();
    }
  }

  void addAlarm(Alarm alarm) {
    alarm.isActive = true;
    _alarms.add(alarm);
    alarmsAnimatedListKey.currentState!.insertItem(alarms.length);
    _scheduleAlarms();
    _saveAlarms();
    notifyListeners();
  }

  void removeAlarm(Alarm alarm) {
    var itemIndex = _alarms.indexOf(alarm);
    var removedItem = _alarms.removeAt(itemIndex);
    _removeAlarmAnimatedListItem(itemIndex, removedItem);
    _scheduleAlarms();
    _saveAlarms();
    notifyListeners();
  }

  void _removeAlarmAnimatedListItem(int itemIndex, Alarm removedItem) {
    /// for perfect animation we set here the isActive property of the removed item
    if (itemIndex > 0 && alarms.length > 0) {
      removedItem.isActive = alarms[itemIndex - 1].isActive;
    }

    alarmsAnimatedListKey.currentState!.removeItem(
      itemIndex + 1,
      (context, animation) => SizeFadeTransition(
        animation: animation,
        child: ListItemPadding(
          child: AlarmClockItem(removedItem),
        ),
      ),
    );
  }

  void updateAlarm(Alarm alarm) {
    _scheduleAlarms();
    _saveAlarms();
    notifyListeners();
  }

  int get numberOfActiveAlarms =>
      _alarms.where((alarm) => alarm.isActive).length;

  void _saveAlarms() {
    _prefs.setString(alarmsPrefsKey, jsonEncode(_alarms));
  }

  void _scheduleAlarms() {
    scheduler?.dispose();
    scheduler = TimeScheduler();
    String today = DateFormat.E().format(DateTime.now());

    Iterable<Alarm> activeAlarmForToday = _alarms.where((alarm) =>
        alarm.isActive &&
        alarm.date.isAfter(DateTime.now()) &&
        (alarm.activeDays.length == 0 ||
            alarm.activeDays.length == 7 ||
            alarm.activeDays.contains(today)));

    if (activeAlarmForToday.length > 0) {
      int nextAlarmTimeStampForToday = activeAlarmForToday
          .map((alarm) => alarm.date.millisecondsSinceEpoch)
          .reduce(min);
      DateTime nextAlarmDateForToday =
          DateTime.fromMillisecondsSinceEpoch(nextAlarmTimeStampForToday);
      Alarm nextAlarmForToday = activeAlarmForToday
          .firstWhere((alarm) => alarm.date == nextAlarmDateForToday);
      scheduler!
          .run(() => startAlarm(nextAlarmForToday), nextAlarmForToday.date);
    }

    DateTime startOfTheNextDay = DateTime.parse(
        DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))));
    scheduler!.run(() => _scheduleAlarms(), startOfTheNextDay);
  }

  Future<void> startAlarm(Alarm alarm) async {
    windowManager.focus().then((_) => windowManager.isFocused().then((focused) {
          if (!focused) windowManager.setSkipTaskbar(false);
        }));

    ReceivePort rPort = ReceivePort();
    rPort.listen((data) {
      if (data is SendPort) {
        data.send(alarm.message);
      } else if (data == 'done') {
        Navigator.pop(navigatorKey.currentContext!);
        Future.delayed(Duration(seconds: 1), stopAlarm);
      }
    });

    await Isolate.spawn(
        alarm.readMessage && alarm.haveMessage
            ? playTextToSpeech
            : startPlaySound,
        rPort.sendPort);

    Navigator.push(navigatorKey.currentContext!,
        FluentPageRoute(builder: (context) => AlarmScreenPage()));

    scheduler!.run(() => stopAlarm(), alarm.date.add(Duration(minutes: 1)));
    _showWindowsToast(alarm);
    notifyListeners();
  }

  Future<void> stopAlarm() async {
    final p = ReceivePort();
    await Isolate.spawn(stopPlaySound, p.sendPort);
    windowManager.setSkipTaskbar(true);
    _scheduleAlarms();
    notifyListeners();
  }

  void _showWindowsToast(Alarm alarm) {
    WinToast.instance().showToast(
        type: ToastType.text02,
        title: DateFormat.yMMMMEEEEd().format(alarm.date),
        subtitle: alarm.message ?? '');
  }
}

Future<void> startPlaySound(SendPort p) async {
  final soundPath = TEXT('$windowsMediaPath/Alarm01.wav');
  PlaySound(soundPath, NULL, SND_FILENAME | SND_ASYNC | SND_LOOP);
  free(soundPath);
  Isolate.exit(p);
}

Future<void> stopPlaySound(SendPort p) async {
  PlaySound(nullptr, NULL, NULL);
  Isolate.exit(p);
}

Future<void> playTextToSpeech(SendPort sPort) async {
  ReceivePort rPort = ReceivePort();
  rPort.listen((message) async {
    await Future.delayed(Duration(seconds: 1)).then((_) {
      final soundPath = TEXT('$windowsMediaPath/Speech On.wav');
      PlaySound(soundPath, NULL, SND_FILENAME | SND_ASYNC);
      free(soundPath);
    });

    await Future.delayed(Duration(seconds: 2)).then((_) {
      CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
      final speechEngine = SpVoice.createInstance();
      final pText = (message as String).toNativeUtf16();
      speechEngine.Speak(pText, SPEAKFLAGS.SPF_IS_NOT_XML, nullptr);
      free(pText);
      CoUninitialize();

      final soundPath = TEXT('$windowsMediaPath/Speech Off.wav');
      PlaySound(soundPath, NULL, SND_FILENAME | SND_ASYNC);
      free(soundPath);
    });

    sPort.send('done');
    Isolate.exit(sPort);
  });

  sPort.send(rPort.sendPort);
}
