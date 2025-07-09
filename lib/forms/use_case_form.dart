import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:video_player/video_player.dart';

import '../components/bottom_nav_widget.dart';
import '../constants/colours.dart';
import '../constants/dimensions.dart';
import '../controllers/use_case_controller.dart';
import '../screens/home_screen.dart';

class UseCaseForm extends StatefulWidget {
  const UseCaseForm({super.key});

  @override
  State<UseCaseForm> createState() => _UseCaseFormState();
}

class _UseCaseFormState extends State<UseCaseForm> {
  late VideoPlayerController controller;
  var useCaseController = Get.find<UseCaseController>();

  bool _isConnected = false;

  Map<String, bool> values = {
    'Estate planning/Executorship': false,
    'Insurance inventory': false,
    'For sale': false,
    'Net worth': false,
    'Divorce/Separation': false,
  };

  late final InternetConnectionCheckerPlus _connectionChecker;

  var tmpArray = [];
  String? selectedCases = '';

  getCheckboxItems() {
    values.forEach((key, value) {
      if (value == true) {
        tmpArray.add(key);
      }
    });

    // Printing all selected items on Terminal screen.

    print(tmpArray.toString().replaceAll('[', '').replaceAll(']', ''));
    selectedCases = tmpArray.toString().replaceAll('[', '').replaceAll(']', '');

    // Here you will get all your selected Checkbox items.

    // Clear array after use.
    tmpArray.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    //readJson();
    loadVideoPlayer();
    // getCheckboxItems();
    super.initState();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();
  }

  Future<void> _checkConnection() async {
    final isConnected = await _connectionChecker.hasConnection;
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _startMonitoring() {
    _connectionChecker.onStatusChange.listen((status) {
      setState(() {
        _isConnected = status == InternetConnectionStatus.connected;
      });
    });
  }

  loadVideoPlayer() {
    controller = VideoPlayerController.asset('assets/images/house.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Stack(
      children: [
        Positioned(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              Text("Total Duration: " + controller.value.duration.toString()),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    backgroundColor: Colors.redAccent,
                    playedColor: Colors.green,
                    bufferedColor: Colors.purple,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }

                              setState(() {});
                            },
                            icon: Icon(controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow)),
                        IconButton(
                            onPressed: () {
                              controller.seekTo(Duration(seconds: 0));

                              setState(() {});
                            },
                            icon: Icon(Icons.stop))
                      ],
                    ),
                    Text(
                      "Please swipe down to see more options",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: values.keys.map((String key) {
                    return new CheckboxListTile(
                      title: new Text(key),
                      value: values[key],
                      activeColor: Colors.deepPurple,
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          values[key] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              BottomNavigationWidget(
                buttonText: 'Next',
                validator: true,
                onPressed: () async {
                  getCheckboxItems();

                  // Save the details into SQLLite database
                  useCaseController.insertUseCaseSQLLite(
                      selectedCases!, selectedCases!);

                  if (_isConnected) {
                    // Make a server api method
                  } else {}

                  Navigator.pushReplacementNamed(context, HomeScreen.screenId);

                  // Navigator.pushNamed(context, HomeScreen.screenId);
                  //Navigator.of(context).pushNamed(AddItemScreen.screenId);
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
