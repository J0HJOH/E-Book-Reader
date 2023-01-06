import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_e_book_reader/file_repository.dart';
import 'package:my_e_book_reader/reader.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var  fileRepo = FileRepository();
  List<String> fileAccessed = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My E-Book Reader"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future:  fileRepo.getFiles(),
        builder: (context, snapshot){
          if(snapshot.data== null) return CircularProgressIndicator();
          //assign data to list of fileAccessed
          fileAccessed = snapshot.data as List<String>;
          return ListView.builder(
              itemCount: fileAccessed.length,
              itemBuilder: (context, index){
                String fileAccessedPath = fileAccessed[index];
                return Dismissible(
                  key: Key(fileAccessedPath),
                  child: Card(
                    child: GestureDetector(
                      onTap: (){
                        openReaderPage(context, File(fileAccessedPath));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          " ${fileAccessedPath.split("/").last}",//-this gets file name
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),

                  ),

                  onDismissed: (dismissDirection) async {
                    fileAccessed.remove(fileAccessedPath);
                    await fileRepo.removeFile(fileAccessedPath);
                    setState(() {});
                  },
                );
              }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _selectFile(context);

        },
        child: Icon(Icons.folder_open),
      ),
    );
  }

  Future<void> _selectFile(BuildContext context) async {
     FilePickerResult? result = await
    FilePicker.platform.pickFiles(
        allowedExtensions: ["pdf"],
      type: FileType.custom
    );
    if(result != null){
      // User selected the file
      //create file instance
      String path = result.files[0].path!;
      File docFile = File(path);

      openReaderPage(context, docFile);

      setState(() {

        checkExistingFile(path);
        fileRepo.saveFiles(fileAccessed);
      });
    }else{
      //user cancelled selection
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File Selection cancelled")
          )
      );
    }
  }

  void checkExistingFile(String path) {
     if(!fileAccessed.contains(path)){
      //add file to list of file accessed
      fileAccessed.add(path);
    }else{
      //brings the chosen file if already existed to the top
      var pathIndex = fileAccessed.indexOf(path);
      String existingPath = fileAccessed.removeAt(pathIndex);
      fileAccessed.add(existingPath);
    }
  }

  void openReaderPage(BuildContext context, File docFile) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)=>ReaderPage(document : docFile))
    );
  }
}
