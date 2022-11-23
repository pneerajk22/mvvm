import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:mvvm/screens/profile.dart';
import 'add_task.dart';
import 'description.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = '';
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
    bool _istap = false;
    return Scaffold(
      drawer: Drawer(child: Container(child: Column(children: [
        Container(height: MediaQuery.of(context).size.height * 0.2,color: Colors.purple,),
        //SizedBox(height: 20,),
        InkWell(
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) =>
            Profile()
          ));},
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(Icons.person_outline,size: 30,),
                SizedBox(width: 10,),
                Text("Profile",style: TextStyle(fontSize: 20),)
              ],
            ),
          ),
        )
      ],),),),
      appBar: AppBar(
        title: Text('TODO'),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(uid)
              .collection("mytasks")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final docs = snapshot.data.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var time = (docs[index]['timestamp'] as Timestamp).toDate();

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Description(
                                    title: docs[index]['title'],
                                    description: docs[index]['description'],
                                  )));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: !docs[index]['done']?Color.fromARGB(255, 103, 103, 84):Color.fromARGB(255, 138, 230, 141),
                          borderRadius: BorderRadius.circular(10)),
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text(docs[index]['title'],
                                        style: TextStyle(fontFamily: 'roboto',fontSize: 20,decoration: !docs[index]['done']?TextDecoration.none:TextDecoration.lineThrough)
                                            )),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text(
                                        DateFormat.yMd().add_jm().format(time)))
                              ]),
                          Spacer(),
                          Spacer(),
                          Spacer(),
                          
                          IconButton(
                            
                            onPressed: () async{
                              await FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(uid)
                                        .collection('mytasks')
                                        .doc(docs[index]['time'])
                                        .update({"done":!docs[index]['done']});
                            },
                            icon:
                             !docs[index]['done']?const Icon(Icons.check_circle_outline):const Icon(Icons.check_circle,color: Colors.green),
                          ),
                          Container(
                              child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(173, 244, 67, 54),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(uid)
                                        .collection('mytasks')
                                        .doc(docs[index]['time'])
                                        .delete();
                                  }))
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        // color: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddTask()));
          }),
    );
  }
}
