import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:rxdart/rxdart.dart';

class NavigationController {
  static NavigationController _instance;
  static dynamic parameters;

  static BehaviorSubject<NavigationTabs> _navigationController = BehaviorSubject.seeded(NavigationTabs(NavTab.FaceDetection));

  NavigationController._();

  factory NavigationController() => _getInstance();

  static NavigationController _getInstance() {
    if (_instance == null) {
      _instance = NavigationController._();
    }
    return _instance;
  }

  static Stream<NavigationTabs> get navigationStream => _navigationController.stream;
  static NavigationTabs get navigation => _navigationController.value;
  static set navigation(NavigationTabs data) => _navigationController.add(data);

  static dispose() {
    _navigationController.close();
  }
}