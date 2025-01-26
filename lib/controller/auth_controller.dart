import 'package:diabetes_tracking/codefusionbit.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => HomeScreen()); // Navigate to HomeScreen
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.offAll(() => HomeScreen()); // Navigate to HomeScreen
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen()); // Navigate to HomeScreen
  }
}