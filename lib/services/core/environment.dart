import 'enum.dart';

class BuildEnvironment<String> extends Enum<String> {
  const BuildEnvironment(String val) : super(val);

  /// PROD
  static const PROD_API = const BuildEnvironment('https://api.kairos.com');
}