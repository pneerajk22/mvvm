import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String uid = '';
  TextEditingController namecontroller = TextEditingController();
  @override
  void initState() {
    getuid();
    super.initState();
  }

  getuid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    setState(() {
      uid = user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      final data =
                          snapshot.data["name"].toString().toUpperCase();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Name:",
                            style: TextStyle(
                                fontSize: 20,),
                          ),
                          SizedBox(height: 20,),
                          Text(data,style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))
                        ],
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  child: TextField(
                    controller: namecontroller,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'New Name',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (() async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({'name': namecontroller.text});
                    Fluttertoast.showToast(msg: 'Name changed');
                    namecontroller.text = "";
                  }),
                  child: Text("Change Name"),
                ),
              ],
            ),
          ),
        ));
  }
}
