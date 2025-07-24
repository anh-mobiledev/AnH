import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pam_app/firebase_options.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/my_items_server_model.dart';
import 'package:pam_app/screens/addItem/add_details.dart';
import 'package:pam_app/screens/addItem/additional_options.dart';
import 'package:pam_app/screens/addItem/howyouwanttodescribeit.dart';
import 'package:pam_app/screens/addItem/source_page.dart';
import 'package:pam_app/screens/addItem/upload_image.dart';
import 'package:pam_app/screens/addItem/upload_video.dart';
import 'package:pam_app/screens/auth/sign_in_with_email_password_screen.dart';
import 'package:pam_app/screens/auth/sign_in_with_username_password_screen.dart';

import 'package:pam_app/screens/intro_screen.dart';

import 'package:pam_app/screens/managepeople/contact_list.dart';
import 'package:pam_app/screens/usecase_screen.dart';

import 'constants/colours.dart';
import 'helper/dependencies.dart' as dep;
import 'screens/addItem/add_item_image.dart';
import 'screens/addItem/add_item_images.dart';
import 'screens/addItem/item_details_view.dart';
import 'screens/addItem/items_list.dart';
import 'screens/addItem/multiple_image_picker.dart';
import 'screens/addItem/whatdoyouwanttonameit.dart';
import 'screens/auth/email_verify_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/myCollections/add_child_collection_screen.dart';
import 'screens/myCollections/add_parent_collection_screen.dart';
import 'screens/myCollections/child_collection_list_screen.dart';
import 'screens/myCollections/parent_collections_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dep.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  DBHelper dbHelper = new DBHelper();
  await dbHelper.initDB();

  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.whiteColor,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
        ),
        fontFamily: 'Oswald',
        //scaffoldBackgroundColor: AppColors.whiteColor, colorScheme: ColorScheme(brightness: Brightness.dark),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.screenId,
      routes: {
        IntroScreen.screenId: (context) => const IntroScreen(),
        SplashScreen.screenId: (context) => const SplashScreen(),
        LoginScreen.screenId: (context) => const LoginScreen(),
        PhoneAuthScreen.screenId: (context) => const PhoneAuthScreen(
              isFromLogin: false,
            ),
        LocationScreen.screenId: (context) => const LocationScreen(),
        HomeScreen.screenId: (context) => const HomeScreen(),
        WelcomeScreen.screenId: (context) => const WelcomeScreen(),
        RegisterScreen.screenId: (context) => const RegisterScreen(),
        EmailVerifyScreen.screenId: (context) => const EmailVerifyScreen(),
        ResetPasswordScreen.screenId: (context) => const ResetPasswordScreen(),
        UsecaseScreen.screenId: (context) => const UsecaseScreen(),
        ProfileScreen.screenId: (context) => const ProfileScreen(),
        AddItemImagesScreen.screenId: (context) => const AddItemImagesScreen(),
        AddItemImageScreen.screenId: (context) => const AddItemImageScreen(),
        MultipleImagePickerScreen.screenId: (context) =>
            const MultipleImagePickerScreen(),
        SourcePage.screenId: (context) => const SourcePage(),
        AddDetailsScreen.screenId: (context) => const AddDetailsScreen(),
        WhatDoYouWantToNameItScreen.screenId: (context) =>
            const WhatDoYouWantToNameItScreen(),
        HowYouWantToDescribeItScreen.screenId: (context) =>
            const HowYouWantToDescribeItScreen(),
        AddionalOptionsScreen.screenId: (context) =>
            const AddionalOptionsScreen(),
        ContactListScreen.screenId: (context) => ContactListScreen(),
        UploadImageScreen.screenId: (context) => UploadImageScreen(),
        UploadVideoScreen.screenId: (context) => UploadVideoScreen(),
        ItemsListScreen.screenId: (context) => ItemsListScreen(),
        ItemDetailsViewScreen.screenId: (context) => ItemDetailsViewScreen(),
        SignInWithUsernamePasswordScreen.screenId: (context) =>
            SignInWithUsernamePasswordScreen(),
        SignInWithEmailPasswordScreen.screenId: (context) =>
            SignInWithEmailPasswordScreen(),
        ParentCollectionsListScreen.screenId: (context) =>
            ParentCollectionsListScreen(),
        AddParentCollectionScreen.screenId: (context) =>
            AddParentCollectionScreen(),
        ChildCollectionsListScreen.screenId: (context) =>
            ChildCollectionsListScreen(),
        AddChildCollectionScreen.screenId: (context) =>
            AddChildCollectionScreen(),
      },
    );
  }
}
