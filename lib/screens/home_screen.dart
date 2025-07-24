import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/screens/auth/login_screen.dart';
import 'package:pam_app/screens/usecase_screen.dart';
import 'package:pam_app/services/auth.dart';
import 'package:pam_app/widgets/big_text.dart';
import 'package:pam_app/widgets/small_text.dart';

import '../constants/imgasset.dart';
import 'addItem/add_item_images.dart';
import 'addItem/items_list.dart';
import 'myCollections/parent_collections_list_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String screenId = 'home_screen';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _fuelController;

  bool _isContactShow = false;
  bool _isValuationShow = false;
  bool _isActivityShow = false;
  bool _isSellItemShow = false;
  bool _isToDoShow = false;
  bool _isTagShow = false;
  bool _isLocationShow = false;
  bool _isAccountShow = false;

  Auth authService = Auth();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    _fuelController = TextEditingController();
    userToken();
    super.initState();
  }

  Future<void> userToken() async {
    String? token = await storage.read(key: 'app_token');
    String? userId = await storage.read(key: 'userId');
    print('app token :: ${token} \n user id ${userId}');
  }

  @override
  void dispose() {
    _fuelController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      await storage.deleteAll();
      Navigator.pushReplacementNamed(
          context, LoginScreen.screenId); // Navigate to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    // var categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.secondaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: Dimensions.height45,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: SmallText(
                  text:
                      "Welcome to your personal dashboard. Here, you can manage your tangible assets and cherished heirlooms — ensuring their value and stories live on.",
                  size: 16,
                  height: 1.2,
                  color: AppColors.greyColor,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(ItemsListScreen.screenId);
                    },
                    child: Image.asset(
                      imgadditem,
                      height: 80,
                      width: 80,
                    ),
                  ),
                  Text("Manage Items"),
                ],
              ),
              SizedBox(
                height: Dimensions.height10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ParentCollectionsListScreen.screenId);
                    },
                    child: Image.asset(
                      imgtodo,
                      height: 80,
                      width: 80,
                    ),
                  ),
                  Text("Manage Collections"),
                ],
              ),
            ],
          ),
        ],
      ),
      /*bottomNavigationBar: BottomNavigationWidget(
        buttonText: 'More actions',
        validator: true,
        onPressed: () {
          _fuelTypeListView(context);
        },
      ),*/ //homeBodyWidget(context),
    );
  }
/*
  Widget makeDashboardItem(String title, Image icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
      ),
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Contacts':
              setState(() {
                _isContactShow = !_isContactShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'Valuation':
              setState(() {
                _isValuationShow = !_isValuationShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'Activity':
              setState(() {
                _isActivityShow = !_isActivityShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'Sell Item':
              setState(() {
                _isSellItemShow = !_isSellItemShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'To Dos':
              setState(() {
                _isToDoShow = !_isToDoShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'Manage Tags':
              setState(() {
                _isTagShow = !_isTagShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'Manage Locations':
              setState(() {
                _isLocationShow = !_isLocationShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            case 'Account':
              setState(() {
                _isAccountShow = !_isAccountShow;
              });
              //Navigator.of(context).pushNamed(AddItemScreen.screenId);
              break;
            default:
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            SizedBox(height: 10.0),
            _bottomIcon(title),
            SizedBox(height: 20.0),
            Center(
              child: Text(title,
                  style: TextStyle(fontSize: 12.0, color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  _bottomIcon(String title) {
    Image? icon;
    switch (title) {
      case 'Contacts':
        setState(() {
          icon = Image.asset(
            imgcontact,
            height: 40,
          );
        });
        //Navigator.of(context).pushNamed(AddItemScreen.screenId);
        break;
      case 'Valuation':
        setState(() {
          icon = Image.asset(
            imgvaluation,
            height: 40,
          );
        });
        break;
      case 'Activity':
        setState(() {
          icon = Image.asset(
            imgactivity,
            height: 40,
          );
        });
        break;
      case 'Sell Item':
        setState(() {
          icon = Image.asset(
            imgsellitem,
            height: 40,
          );
        });
        break;
      case 'To Dos':
        setState(() {
          icon = Image.asset(
            imgtodo,
            height: 40,
          );
        });
        break;
      case 'Manage Tags':
        setState(() {
          icon = Image.asset(
            imgtag,
            height: 40,
          );
        });
        break;
      case 'Manage Locations':
        setState(() {
          icon = Image.asset(
            imglocation,
            height: 40,
          );
        });
        break;
      case 'Account':
        setState(() {
          icon = Image.asset(
            imgaccount,
            height: 40,
          );
        });
        break;
    }
    return Center(child: icon);
  }

  _fuelTypeListView(BuildContext context) {
    return openBottomSheet(
      context: context,
      appBarTitle: 'More actions',
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        padding: EdgeInsets.all(3.0),
        children: <Widget>[
          makeDashboardItem("Contacts", Image.asset(imgcontact)),
          makeDashboardItem("Valuation", Image.asset(imgvaluation)),
          makeDashboardItem("Activity", Image.asset(imgactivity)),
          makeDashboardItem("Sell Item", Image.asset(imgsellitem)),
          makeDashboardItem("To Dos", Image.asset(imgtodo)),
          makeDashboardItem("Manage Tags", Image.asset(imgtag)),
          makeDashboardItem("Manage Locations", Image.asset(imglocation)),
          makeDashboardItem("Account", Image.asset(imgaccount)),
        ],
      ),
    );
  }
*/
}

class locationTextWidget extends StatelessWidget {
  final String? location;
  const locationTextWidget({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.pin_drop,
          size: 18,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          location ?? '',
          style: TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
