import 'package:diabetes_tracking/codefusionbit.dart';

class ThemeController extends GetxController {
  final storage = GetStorage();
  final RxBool _isDarkMode = false.obs;
  final String _themeKey = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = storage.read(_themeKey) ?? false;
    updateTheme();
  }

  bool get isDarkMode => _isDarkMode.value;

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    storage.write(_themeKey, _isDarkMode.value);
    updateTheme();
  }

  void updateTheme() {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}