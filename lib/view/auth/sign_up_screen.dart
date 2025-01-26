import 'package:diabetes_tracking/codefusionbit.dart';

class SignUpScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Create New Account',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty &&
                              confirmPasswordController.text.isNotEmpty) {
                            if (passwordController.text ==
                                confirmPasswordController.text) {
                              authController.signUp(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Passwords do not match',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please fill in all fields',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Obx(() => authController.isLoading.value
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : Text('Create Account')),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Already have an account? Sign In'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}