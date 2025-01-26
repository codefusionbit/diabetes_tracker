import 'package:diabetes_tracking/codefusionbit.dart';

class GlucoseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find();

  final selectedFilter = "1M".obs;
  // Observable values
  final RxList<DailyReading> readings = <DailyReading>[].obs;
  final Rx<DailyReading?> lastReading = Rx<DailyReading?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.user, _onUserChanged);
  }

  void _onUserChanged(User? user) {
    if (user != null) {
      _subscribeToReadings(user.uid);
    } else {
      readings.clear();
      lastReading.value = null;
    }
  }

  void _subscribeToReadings(String userId) {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_readings')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      readings.value = snapshot.docs.map((doc) {
        final map = DailyReading.fromFirestore(doc);
        return map;
      }).toList();
      lastReading.value = readings.isNotEmpty ? readings.first : null;
    }, onError: (error) {
      Get.snackbar(
        'Error',
        'Failed to load readings: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  Future<void> updateReading({
    required DateTime date,
    double? fastingValue,
    DateTime? fastingDate,
    double? nonFastingValue,
    DateTime? nonFastingDate,
  }) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value!.uid;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_readings')
          .doc(dateOnly.toIso8601String());

      final existingDoc = await docRef.get();
      if (existingDoc.exists) {
        //final existing = DailyReading.fromFirestore(existingDoc);
        await docRef.update({
          if (fastingValue != null) 'fastingValue': fastingValue,
          if (fastingDate != null)
            'fastingDate': Timestamp.fromDate(fastingDate),
          if (nonFastingValue != null) 'nonFastingValue': nonFastingValue,
          if (nonFastingDate != null)
            'nonFastingDate': Timestamp.fromDate(nonFastingDate),
        });
      } else {
        await docRef.set(DailyReading(
          date: dateOnly,
          fastingValue: fastingValue,
          fastingDate: fastingDate,
          nonFastingValue: nonFastingValue,
          nonFastingDate: nonFastingDate,
          foodRecords: [],
        ).toJson());
      }
      Get.snackbar('Success', 'Reading updated successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update reading: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFoodRecord(DateTime date, FoodRecord record) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value!.uid;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_readings')
          .doc(dateOnly.toIso8601String());

      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set(DailyReading(
          date: dateOnly,
          foodRecords: [record],
        ).toJson());
      } else {
        await docRef.update({
          'foodRecords': FieldValue.arrayUnion([record.toJson()])
        });
      }
      Get.snackbar('Success', 'Food record added successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add food record: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFoodRecord(
      String readingId,
      FoodRecord oldRecord,
      FoodRecord newRecord,
      ) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value!.uid;
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_readings')
          .doc(readingId);

      final batch = _firestore.batch();
      batch.update(docRef, {
        'foodRecords': FieldValue.arrayRemove([oldRecord.toJson()]),
      });
      batch.update(docRef, {
        'foodRecords': FieldValue.arrayUnion([newRecord.toJson()]),
      });

      await batch.commit();
      Get.snackbar('Success', 'Food record updated successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update food record: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void confirmDeleteDailyReading(String readingId) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this daily reading?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.red,
      onConfirm: () async {
        await deleteDailyReading(readingId);
      },
      onCancel: () {
        Get.back(); // Close the dialog without deleting
      },
    );
  }

  Future<void> deleteDailyReading(String readingId) async {
    try {
      // Indicate that the deletion process is in progress
      isLoading.value = true;

      // Get the current user's ID
      final userId = _authController.user.value!.uid;

      // Reference the specific document in Firestore
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_readings')
          .doc(readingId);

      // Delete the document
      await docRef.delete();

      // Show a success message
      Get.snackbar('Success', 'Daily reading deleted successfully');
    } catch (e) {
      // Show an error message if the deletion fails
      Get.snackbar(
        'Error',
        'Failed to delete daily reading: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Reset the loading indicator
      isLoading.value = false;
    }
  }

  Future<void> deleteFoodRecord(String readingId, FoodRecord record) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value!.uid;
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_readings')
          .doc(readingId);

      await docRef.update({
        'foodRecords': FieldValue.arrayRemove([record.toJson()])
      });
      Get.snackbar('Success', 'Food record deleted successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete food record: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}