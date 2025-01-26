export 'dart:async';
export 'dart:io';
export 'dart:convert';
export 'dart:math';

///FLUTTER PACKAGE/DEPENDENCIES
export 'package:flutter/material.dart';
export 'package:flutter/foundation.dart';
export 'package:flutter/services.dart';
export 'package:flutter/gestures.dart';



///FIREBASE PACKAGE/DEPENDENCIES
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart' hide kIsWasm;


///OTHER PACKAGE/DEPENDENCIES
export 'package:fl_chart/fl_chart.dart';
export 'package:get_storage/get_storage.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:diabetes_tracking/widget/horizontal_list_view.dart';
export 'package:get/get.dart' hide HeaderValue;


/// CONTROLLERS
export 'package:diabetes_tracking/controller/theme_controller.dart';
export 'package:diabetes_tracking/controller/auth_controller.dart';
export 'package:diabetes_tracking/controller/glucose_controller.dart';


/// View
export 'package:diabetes_tracking/view/dashboard/home_screen.dart';
export 'package:diabetes_tracking/view/auth/login_screen.dart';
export 'package:diabetes_tracking/view/auth/sign_up_screen.dart';

/// MODELS
export 'package:diabetes_tracking/model/daily_reading.dart';
export 'package:diabetes_tracking/model/food_record.dart';


/// WIDGET
export 'package:diabetes_tracking/widget/snap_scroll_physic.dart';