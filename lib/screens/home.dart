// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coffee_shop/l10n/app_localizations.dart';
import 'package:coffee_shop/language.dart';
import 'package:coffee_shop/providers/theme_provider.dart';
import 'package:coffee_shop/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController date = TextEditingController();
  

    DateTime? selectedDate;

  pickDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context, 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),
      initialDate: selectedDate?? DateTime.now(),
      );

       if(picked != null && picked != selectedDate){
        setState(() {
          selectedDate = picked;
          date.text = "${picked.day}-${picked.month}-${picked.year}";
        });
       }
  }

  final user = FirebaseAuth.instance.currentUser;
  int currentindex = 0;

  signOut()async{
    await FirebaseAuth.instance.signOut();
  }

  Stream? ListStream;
  Set<String> selectedTasks = {};

  getontheload() async{
    ListStream = await DatabaseMethod().getLists();
    setState(() {
      
    });
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }
   
   Widget allList(){
    final localizations = ref.read(appLocalizationsProvider);
    return StreamBuilder(stream: ListStream, builder: (context,AsyncSnapshot snapshot){
      if(!snapshot.hasData) return Container();
      var userAuth = snapshot.data.docs.where((doc)=> doc["UserId"]==user!.uid).toList();
      if(userAuth.isEmpty) return Center(child: Text('No Tasks'),);
      return ListView.builder(
        itemCount: userAuth.length,
        itemBuilder: (context,index){
          DocumentSnapshot ds = userAuth[index];
          String taskId = ds["Id"];
          bool isChecked = ds["isChecked"] ?? false;
          return GestureDetector(
           onTap: () async{
              await DatabaseMethod().updateCheckedTask(taskId,!isChecked);
            },
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Material(
                    borderRadius: BorderRadius.circular(10),
                    color: isChecked ?  Colors.brown : Colors.pink.shade200,
                    elevation: 0.5,
                    child: Container(
                      margin: EdgeInsets.only(top: 10,bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                           Icon(
                            isChecked
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank,
                            color: Colors.white,
                            size: 40.0,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Text('${ds["Title"]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),softWrap: true,overflow: TextOverflow.visible,maxLines: null,)
                                      ),
                                    SizedBox(
                                      width: 180,
                                      child: Text('${ds["Content"]}',style: TextStyle(fontSize: 20),softWrap: true,overflow: TextOverflow.visible,maxLines: null,)
                                      ),
                                    Text('${ds["Date"]}',style: TextStyle(fontSize: 20),),
                                  ],
                                ),
                                 Column(
                                    children: [
                                      ElevatedButton(onPressed: (){
                                        EditList(ds["Id"]);
                                      }, child: Row(
                                        children: [
                                          Text(localizations.edit),
                                          SizedBox(width: 5),
                                          Icon(Icons.edit)
                                        ],
                                      ),),
                                      // ignore: sort_child_properties_last
                                      ElevatedButton(onPressed: (){FirebaseFirestore.instance.collection("List").doc(ds["Id"]).delete();}, child: Row(
                                        children: [
                                          Text(localizations.delete,style: TextStyle(color: Colors.white),),
                                          SizedBox(width: 5),
                                          Icon(Icons.delete,color: Colors.white,)
                                        ],
                                      ),style: ElevatedButton.styleFrom(backgroundColor: Colors.red),)
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          );
        });
    });
   }

   Widget todayList() {
    final localizations = ref.read(appLocalizationsProvider);
  return StreamBuilder(
    stream: ListStream,
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) return Container();
       var userAuth = snapshot.data.docs.where((doc)=> doc["UserId"]==user!.uid).toList();
      if(userAuth.isEmpty) return Center(child: Text('No Tasks'),);
      DateTime today = DateTime.now();
      var todayDocs =userAuth.where((doc) {
        try {
          String dateStr = doc["Date"];
          List<String> parts = dateStr.split("-");
          if (parts.length == 3) {
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);
            DateTime itemDate = DateTime(year, month, day);
            return itemDate.year == today.year &&
                itemDate.month == today.month &&
                itemDate.day == today.day;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();

      return ListView.builder(
        itemCount: todayDocs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot ds = todayDocs[index];
          String taskId = ds["Id"];
          bool isChecked = ds["isChecked"] ?? false;

          return GestureDetector(
            onTap: () async{
              await DatabaseMethod().updateCheckedTask(taskId,!isChecked);
            },
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: isChecked ?  Colors.brown : Colors.pink.shade200 ,
                elevation: 0.5,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(
                        isChecked
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    '${ds["Title"]}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    maxLines: null,
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    '${ds["Content"]}',
                                    style: TextStyle(fontSize: 20),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    maxLines: null,
                                  ),
                                ),
                                Text(
                                  '${ds["Date"]}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    EditList(ds["Id"]);
                                  },
                                  child: Row(
                                    children: [
                                      Text(localizations.edit),
                                      SizedBox(width: 5),
                                      Icon(Icons.edit)
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection("List")
                                        .doc(ds["Id"])
                                        .delete();
                                  },
                                  // ignore: sort_child_properties_last
                                  child: Row(
                                    children: [
                                      Text(localizations.delete,style: TextStyle(color: Colors.white),),
                                      SizedBox(width: 5),
                                      Icon(Icons.delete,color: Colors.white,)
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    final selectedLanguage = ref.watch(LanguageProvider);
    final localizations = ref.read(appLocalizationsProvider);
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.todolist,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),actions: [Container(padding: EdgeInsets.only(right: 10.0), child: Row(
        children: [
          TextButton.icon(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));},icon: Icon(Icons.person), label: Text('${user?.displayName}')),
          IconButton(onPressed: () => signOut(), icon: Icon(Icons.logout_rounded))
        ],
      ))],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentindex = index;
          });
        },
        selectedIndex: currentindex,
        indicatorColor: Colors.amber,
        destinations: <Widget>[
          NavigationDestination( 
              icon: Badge(child: Icon(Icons.task),), 
              label: localizations.alltasks,
            ),
            NavigationDestination(
              icon: Badge(child: Icon(Icons.today),),
              label: localizations.todaytask
              ),
             NavigationDestination(
              icon: Icon(Icons.settings),
              label: localizations.setting
              ),
        ]
      ),
      body: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(localizations.alltasks,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Expanded(child: allList())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(localizations.todaytask,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Expanded(child: todayList())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(localizations.setting,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Row(
                children: [
                  Text(localizations.light),
                  Switch(
                    value: appThemeState.isDarkModeEnabled, 
                    onChanged: (enable){
                      if (enable){
                        appThemeState.setDarkTheme();
                      }else{
                        appThemeState.setLightTheme();
                      }
                    }
                    ),
                    Text(localizations.dark)
                ],
              ),
             Row(
              children: [
                Text(localizations.language),
                SizedBox(width: 30,),
                 DropdownButton<Language>(
                  value: selectedLanguage,
                  items: Language.values.map((lang) {
                    return DropdownMenuItem<Language>(
                      value: lang,
                      child: Row(
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(lang.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (lang) {
                    if (lang != null) {
                      ref.read(LanguageProvider.notifier).state = lang;
                    }
                  },
                ),
              ],
            ),

            ],
          ),
        ),
      ][currentindex],
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ListForm()));
      },child: Icon(Icons.add),),
      );
  }

  EditList(String id)async{ 
    final localizations = ref.read(appLocalizationsProvider);
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("List").doc(id).get();
    title.text = ds["Title"];
    content.text = ds["Content"];
    date.text = ds["Date"];
  showDialog(
  // ignore: use_build_context_synchronously
  context: context,
  builder: (context) => AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(localizations.editform, style: TextStyle(fontSize: 24)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.cancel),
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizations.reqtitle,
            ),
            controller: title,
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizations.reqcontent,
            ),
            controller: content,
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: localizations.reqdate,
              icon: Icon(Icons.calendar_today),
            ),
            controller: date,
            readOnly: true,
            onTap: () => pickDate(context),
          ),
        ],
      ),
    ),
    actions: [
      ElevatedButton(
        onPressed: () {
          FirebaseFirestore.instance.collection("List").doc(id).update({
            "Title": title.text,
            "Content": content.text,
            "Date": date.text,
            "UserId" : user?.uid,
          });
          Navigator.pop(context);
        },
        child: Text(localizations.save),
      ),
    ],
  ),
);
}
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

final user = FirebaseAuth.instance.currentUser;

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Profile',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Your Name : ',style: TextStyle(fontWeight: FontWeight.bold),),
                Text('${user?.displayName}',style: TextStyle(fontWeight: FontWeight.bold,color: const Color(0xFF3606F5)),),
                IconButton(onPressed: () => EditName(), icon: Icon(Icons.edit))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Your Email : ',style: TextStyle(fontWeight: FontWeight.bold),),
                Text('${user?.email}',style: TextStyle(fontWeight: FontWeight.bold,color: const Color(0xFF3606F5)),),
                IconButton(onPressed: () => EditEmail(), icon: Icon(Icons.edit))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Your Password : ',style: TextStyle(fontWeight: FontWeight.bold),),
                Text('********',style: TextStyle(fontWeight: FontWeight.bold,color: const Color(0xFF3606F5)),),
                IconButton(onPressed: () {
                  if (user?.email != null) {
                  FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!).then((_){
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email Sent to ${user?.email}! Please check your email and change your password!'),backgroundColor: Colors.lightGreen,)
                    );
                  }).catchError((e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error found : ${e.toString()}'),backgroundColor: Colors.red,)
                    );
                  });
                  }}, icon: Icon(Icons.edit))
              ],
            ),
          )
        ],
      ),
    );
  }

User? user = FirebaseAuth.instance.currentUser;
EditName() async{
  // ignore: no_leading_underscores_for_local_identifiers
  final TextEditingController _nameController =
      TextEditingController(text: user?.displayName ?? "");
  showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Update Your Name', style: TextStyle(fontSize: 20)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.cancel),
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
         mainAxisSize: MainAxisSize.min, 
        children: [
          SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter New Name',
            ), 
          ),
        ]
      ),
    ),
     actions: [
      ElevatedButton(
        onPressed: () {
          if (user != null && _nameController.text.isNotEmpty) {
                   user?.updateDisplayName(_nameController.text.trim()); 
                   setState(() {
                      user = FirebaseAuth.instance.currentUser;
                   });
                   user?.reload();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Name updated successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
          Navigator.pop(context);
          }
        },
        child: Text('Save'),
      ),
    ],
  ));
}


EditEmail(){
  final TextEditingController _emailController =
      TextEditingController(text: user?.email ?? "");
  showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Update Your Email', style: TextStyle(fontSize: 20)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.cancel),
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
         mainAxisSize: MainAxisSize.min, 
        children: [
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter New Email',
            ), 
          ),
        ]
      ),
    ),
     actions: [
      ElevatedButton(
        onPressed: () {
          if (user != null && _emailController.text.isNotEmpty) {
            user!.verifyBeforeUpdateEmail(_emailController.text.trim()).then((_){
            setState(() {
              user = FirebaseAuth.instance.currentUser;
            });
            user?.reload();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Verification email sent to ${_emailController.text}"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
            }).catchError((e){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error : ${e.toString()}'),
              backgroundColor: Colors.red,
              )
            );
            });     
          }
        },
        child: Text('Save'),
      ),
    ],
  ));
}
}

class ListForm extends StatefulWidget {
  const ListForm({super.key});

  @override
  State<ListForm> createState() => _ListFormState();
}

class _ListFormState extends State<ListForm> {

  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController date = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  DateTime? selectedDate;

  pickDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context, 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),
      initialDate: selectedDate?? DateTime.now(),
      );

       if(picked != null && picked != selectedDate){
        setState(() {
          selectedDate = picked;
          date.text = "${picked.day}-${picked.month}-${picked.year}";
        });
       }
  }

  @override
  Widget build(BuildContext context) {
     return Consumer(
      builder: (context, ref, child) {
        final localizations = ref.watch(appLocalizationsProvider);
        
   return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Add List',style: TextStyle(fontSize: 30),),
        ],
      ),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.only(top: 10.0),
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: localizations.reqtitle),
                  controller: title,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: localizations.reqcontent),
                  controller: content,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: localizations.reqdate,icon: Icon(Icons.calendar_today)),
                  controller: date,
                  onTap: () => pickDate(context),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: EdgeInsets.all(10), child: ElevatedButton(
                    onPressed: ()async{
                      String Id = randomAlphaNumeric(10);
                      Map<String,dynamic> listinfo={
                        "Id" : Id,
                        "Title" : title.text,
                        "Content" : content.text,
                        "Date" : date.text,
                        "UserId" : user?.uid,
                        "isChecked" : false
                      };
                      await DatabaseMethod().addToDoList(listinfo, Id).then(Get.snackbar('List Add Successful ✅',' ',backgroundColor: Colors.green.shade300,));
                      // Navigator.pop(context);
                    }, 
                    child: Text('Add',style: TextStyle(fontSize: 20)))),
                ],
              )
              
          ],
        ),
      
      ),
    );
  }
    );
  }
}