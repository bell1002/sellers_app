import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
import 'order_card.dart';

class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
                  Colors.black45,
                  Colors.indigoAccent,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text(
          "New Orders",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("status", isEqualTo: "normal")
            .where("sellerUID", isEqualTo: sharedPreferences!.getString("uid"))
            .orderBy("orderTime", descending: true)
            .snapshots(),
        builder: (c, AsyncSnapshot dataSnapShot) {
          if (dataSnapShot.hasData) {
            return ListView.builder(
              itemCount: dataSnapShot.data.docs.length,
              itemBuilder: (c, index) {
                List<String> productIDs = cartMethods.separateOrderItemIDs(
                    (dataSnapShot.data.docs[index].data()
                        as Map<String, dynamic>)["productIDs"]);
                if (productIDs.isNotEmpty) {
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection("items")
                        .where("itemID",
                            whereIn: productIDs)
                        .where("sellerUID",
                            whereIn: (dataSnapShot.data.docs[index].data()
                                as Map<String, dynamic>)["uid"])
                        .orderBy("publishedDate", descending: true)
                        .get(),
                    builder: (c, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return OrderCard(
                          itemCount: snapshot.data.docs.length,
                          data: snapshot.data.docs,
                          orderId: dataSnapShot.data.docs[index].id,
                          seperateQuantitiesList:
                              cartMethods.separateOrderItemsQuantities(
                                  (dataSnapShot.data.docs[index].data()
                                      as Map<String, dynamic>)["productIDs"]),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No data exists.",
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No data exists.",
                    ),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text(
                "No data exists.",
              ),
            );
          }
        },
      ),
    );
  }
}
