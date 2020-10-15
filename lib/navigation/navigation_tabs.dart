class NavigationTabs {
  final NavTab tab;
  final dynamic params;
  const NavigationTabs(this.tab, {this.params});
}

enum NavTab {
  LoginDni,
  FaceEnroll,
  FaceDetection,
  FaceComparison,
  Home,
}