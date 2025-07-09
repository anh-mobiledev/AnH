import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/validators.dart';
import 'package:pam_app/constants/widgets.dart';
import 'package:pam_app/screens/home_screen.dart';

import '../common/alert.dart';
import '../controllers/auth_controller.dart';
import '../services/user.dart';
import '../utils.dart';

class LocationScreen extends StatefulWidget {
  final bool? onlyPop;
  final String? popToScreen;
  static const String screenId = 'location_screen';
  const LocationScreen({
    this.popToScreen,
    this.onlyPop,
    Key? key,
  }) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.secondaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed(HomeScreen.screenId);
            },
          ),
          title: Text(
            'Choose your location',
            style: TextStyle(color: AppColors.whiteColor),
          ),
        ),
        body: _body(context),
        bottomNavigationBar: BottomLocationPermissionWidget(
            onlyPop: widget.onlyPop, popToScreen: widget.popToScreen ?? ''));
  }

  Widget _body(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          width: 300,
          child: Lottie.asset(
            'assets/lottie/location_lottie.json',
          ),
        ),
      ],
    );
  }
}

class BottomLocationPermissionWidget extends StatefulWidget {
  final bool? onlyPop;
  final String popToScreen;

  const BottomLocationPermissionWidget({
    required this.popToScreen,
    this.onlyPop,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomLocationPermissionWidget> createState() =>
      _BottomLocationPermissionWidgetState();
}

class _BottomLocationPermissionWidgetState
    extends State<BottomLocationPermissionWidget> {
  UserService firebaseUser = UserService();
  Position? position;

  var authController = Get.find<AuthController>();
  Dialogs alert = Dialogs();

  late final TextEditingController _locationNameController;
  late final FocusNode _locationNameNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: roundedButton(
          context: context,
          text: 'Choose Location',
          textColor: AppColors.whiteColor,
          bgColor: AppColors.secondaryColor,
          onPressed: () {
            openLocationBottomsheet(context);
          }),
    );
  }

  @override
  void initState() {
    _locationNameController = TextEditingController();
    _locationNameNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }

  openLocationBottomsheet(BuildContext context) {
    String countryValue = '';
    String stateValue = '';
    String cityValue = '';
    String address = '';
    String manualAddress = '';
    loadingDialogBox(context, 'Fetching details..');

    getLocationAndAddress(context).then((location) {
      if (location != null) {
        Navigator.pop(context);
        setState(() {
          address = location;
        });
        showModalBottomSheet(
            isScrollControlled: true,
            enableDrag: true,
            context: context,
            builder: (context) {
              return Container(
                color: AppColors.whiteColor,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    AppBar(
                      automaticallyImplyLeading: false,
                      iconTheme: IconThemeData(
                        color: AppColors.blackColor,
                      ),
                      elevation: 1,
                      backgroundColor: AppColors.whiteColor,
                      title: Row(children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.clear,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Select Location',
                          style: TextStyle(color: AppColors.blackColor),
                        )
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                          focusNode: _locationNameNode,
                          controller: _locationNameController,
                          validator: (value) {
                            return checkNullEmptyValidation(
                                value, _locationNameController.text);
                          },
                          decoration: InputDecoration(
                              hintText: 'Enter name of the location',
                              hintStyle: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 12,
                              ),
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        decoration: InputDecoration(
                            suffixIcon: const Icon(Icons.search),
                            hintText: 'Select city, area or neighbourhood',
                            hintStyle: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        loadingDialogBox(context, 'Updating location..');
                        await getCurrentLocation(
                                context, serviceEnabled, permission)
                            .then((value) {
                          if (value != null) {
                            List<String> list = value.toString().split(',');

                            List<String> lat = list[0].split(':');
                            print('lat value :: ${lat[1]}');

                            List<String> long = list[1].split(':');
                            print('long value :: ${long[1]}');

                            authController.insertUserLocationInfo_SQLLite(
                                _locationNameController.text,
                                long[1],
                                lat[1],
                                manualAddress,
                                cityValue,
                                stateValue,
                                countryValue);
                            Navigator.of(context)
                                .pushNamed(HomeScreen.screenId);

                            /*authController.AddUserLocation(
                                    _locationNameController.text,
                                    long[1],
                                    lat[1],
                                    manualAddress,
                                    cityValue,
                                    stateValue,
                                    countryValue)
                                .then((response) {
                              if (response.isSuccess) {
                                Navigator.of(context)
                                    .pushNamed(UsecaseScreen.screenId);
                              }
                            });*/
                          }
                        });
                      },
                      horizontalTitleGap: 0,
                      leading: Icon(
                        Icons.my_location,
                        color: AppColors.secondaryColor,
                      ),
                      title: Text(
                        'Use current Location',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        address == '' ? 'Fetch current Location' : address,
                        style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    /*Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Text(
                        'Choose City',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: CSCPicker(
                        layout: Layout.vertical,
                        defaultCountry: CscCountry.United_States,
                        flagState: CountryFlag.ENABLE,
                        dropdownDecoration:
                            const BoxDecoration(shape: BoxShape.rectangle),
                        onCountryChanged: (value) async {
                          setState(() {
                            countryValue = value;
                          });
                        },
                        onStateChanged: (value) async {
                          setState(() {
                            if (value != null) {
                              stateValue = value;
                            }
                          });
                        },
                        onCityChanged: (value) async {
                          setState(() {
                            if (value != null) {
                              cityValue = value;
                              manualAddress = "$cityValue, $stateValue";
                              print(manualAddress);
                            }
                          });
                          if (value != null) {
                            authController.insertUserLocationInfo_SQLLite(
                                _locationNameController.text,
                                "",
                                "",
                                manualAddress,
                                cityValue,
                                stateValue,
                                countryValue);
                            Navigator.of(context)
                                .pushNamed(HomeScreen.screenId);

                            /*authController.AddUserLocation(
                                    _locationNameController.text,
                                    "long",
                                    "lat",
                                    manualAddress,
                                    cityValue,
                                    stateValue,
                                    countryValue)
                                .then(
                              (response) {
                                if (response.isSuccess) {
                                  Navigator.of(context)
                                      .pushNamed(HomeScreen.screenId);
                                } else {}
                              },
                            );*/

                            /* firebaseUser.updateFirebaseUser(context, {
                              'address': manualAddress,
                              'state': stateValue,
                              'city': cityValue,
                              'country': countryValue
                            }).then((value) {
                              if (kDebugMode) {
                                print(
                                    manualAddress + 'inside manual selection');
                              }
                              return (widget.onlyPop == true)
                                  ? (widget.popToScreen.isNotEmpty)
                                      ? Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              widget.popToScreen,
                                              (route) => false)
                                      : Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              MainNavigationScreen.screenId,
                                              (route) => false)
                                  : Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                          MainNavigationScreen.screenId,
                                          (route) => false);
                            });*/
                          }
                        },
                      ),
                    ),*/
                  ],
                ),
              );
            });
      } else {
        Navigator.pop(context);
      }
    });
  }
}
