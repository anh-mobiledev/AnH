//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../services/user.dart';

class MainAppBarWithSearch extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  const MainAppBarWithSearch({
    required this.controller,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<MainAppBarWithSearch> createState() => _MainAppBarWithSearchState();
}

class _MainAppBarWithSearchState extends State<MainAppBarWithSearch> {
  // static List<Products> products = [];
  Auth authService = Auth();
  //Search searchService = Search();
  String address = '';
  //UserService firebaseUser = UserService();
  //DocumentSnapshot? sellerDetails;
  @override
  void initState() {
    /* authService.products.get().then(((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        products.add(Products(
            document: doc,
            title: doc['title'],
            description: doc['description'],
            category: doc['category'],
            subcategory: doc['subcategory'],
            price: doc['price'],
            postDate: doc['posted_at']));
        getSellerAddress(doc['seller_uid']);
      });
    }));*/
    super.initState();
  }

 /* getSellerAddress(selledId) {
     firebaseUser.getSellerData(selledId).then((value) => {
          setState(() {
            address = value['address'];
            sellerDetails = value;
          })
        });
  }*/

  @override
  Widget build(BuildContext context) {
    //  var provider = Provider.of<ProductProvider>(context);
    return SafeArea(
      child: Container(
        height: 70,
        color: Colors.transparent,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Assets and Heirlooms",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 34,
                  ),
                ),
                InkWell(
                  onTap: () {
                    /*  searchService.searchQueryPage(
                        context: context,
                        products: products,
                        address: address,
                        sellerDetails: sellerDetails,
                        provider: provider);*/
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColors.disabledColor.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.search,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
