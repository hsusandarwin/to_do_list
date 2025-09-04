import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_shop/l10n/app_localizations.dart';
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
                                    Container(
                                      width: 180,
                                      child: Text('${ds["Title"]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),softWrap: true,overflow: TextOverflow.visible,maxLines: null,)
                                      ),
                                    Container(
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
                                          Text(AppLocalizations.of(context)!.edit),
                                          SizedBox(width: 5),
                                          Icon(Icons.edit)
                                        ],
                                      ),),
                                      ElevatedButton(onPressed: (){FirebaseFirestore.instance.collection("List").doc(ds["Id"]).delete();}, child: Row(
                                        children: [
                                          Text(AppLocalizations.of(context)!.delete,style: TextStyle(color: Colors.white),),
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
                                Container(
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
                                Container(
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
                                      Text(AppLocalizations.of(context)!.edit),
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
                                  child: Row(
                                    children: [
                                      Text(AppLocalizations.of(context)!.delete,style: TextStyle(color: Colors.white),),
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

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.todolist,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),actions: [Container(padding: EdgeInsets.only(right: 10.0), child: Row(
        children: [
          Icon(Icons.person),
          Text('${user?.displayName}'),
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
              label: AppLocalizations.of(context)!.alltasks,
            ),
            NavigationDestination(
              icon: Badge(child: Icon(Icons.today),),
              label: AppLocalizations.of(context)!.todaytask
              ),
             NavigationDestination(
              icon: Icon(Icons.settings),
              label: AppLocalizations.of(context)!.setting
              ),
        ]
      ),
      body: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.alltasks,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Expanded(child: allList())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.todaytask,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Expanded(child: todayList())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.setting,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.light),
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
                    Text(AppLocalizations.of(context)!.dark)
                ],
              ),
             Row(
              children: [
                Text(AppLocalizations.of(context)!.language),
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
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("List").doc(id).get();
    title.text = ds["Title"];
    content.text = ds["Content"];
    date.text = ds["Date"];
  showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Edit List Form', style: TextStyle(fontSize: 24, color: Colors.brown)),
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
              labelText: 'Enter Title...',
            ),
            controller: title,
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Content...',
            ),
            controller: content,
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Pick Date...',
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
        child: Text("Save"),
      ),
    ],
  ),
);
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
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Enter Title....'),
                  controller: title,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Enter Content....'),
                  controller: content,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: TextField(
                  decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Pick Date....',icon: Icon(Icons.calendar_today)),
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
                    }, 
                    child: Text('Add',style: TextStyle(fontSize: 20)))),
                ],
              )
              
          ],
        ),
      ),
    );
  }
}