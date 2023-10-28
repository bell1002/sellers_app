
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/brandsScreen/upload_bands_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart' ;
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/push_notifications/push_notifications_system.dart';

import '../functions/functions.dart';
import '../models/brands.dart';
import '../splashScreen/my_splash_screen.dart';
import '../widgets/my_drawer.dart';
import '../widgets/text_delegate_header_widget.dart';
import 'brands_ui_design_widget.dart';


class HomeScreen extends StatefulWidget {


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  getSellerEarningFromDatabase(){
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((dataSnapshot) {
         previousEarning= dataSnapshot.data()!["earnings"].toString();
    }).whenComplete(() {
      restrictBlockedUsersFromUsingUsersApp();
    });
  }

  restrictBlockedUsersFromUsingUsersApp() async{
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((snapshot) {
      if(snapshot.data()!["status"] != "approved"){
        showReusableSnackBar(context, "You are blocked by admin");
        showReusableSnackBar(context, "contact admin: admin2@ishop.com ");

        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=>MySplashScreen()));
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    PushNotificationsSystem pushNotificationsSystem = PushNotificationsSystem();
    pushNotificationsSystem.whenNotificationReceived(context);
    pushNotificationsSystem.generateDeviceRecognitionToken();

    getSellerEarningFromDatabase();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black45,
                Colors.indigoAccent,
              ],
              begin: FractionalOffset(0.0,0.0),
              end: FractionalOffset(1.0,0.0),
              stops: [0.0,1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "iShop",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c)=>UploadBrandsScreen()));
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(title: "My Brands"),
          ),

          //1. write query
          //2  model
          //3. ui design widget

          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(sharedPreferences!.getString("uid"))
                .collection("brands")
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot dataSnapshot)
            {
              if(dataSnapshot.hasData) //if brands exists
                  {
                //display brands
                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 1,
                  staggeredTileBuilder: (c)=>  const StaggeredTile.fit(1),
                  itemBuilder: (context, index)
                  {
                    Brands brandsModel = Brands.fromJson(
                      dataSnapshot.data.docs[index].data() as Map<String, dynamic>,
                    );

                    return BrandsUiDesignWidget(
                      model: brandsModel,
                      context: context,
                    );
                  },
                  itemCount: dataSnapshot.data.docs.length,
                );
              }
              else //if brands NOT exists
                  {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "No brands exists",
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
