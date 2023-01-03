import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_e_book_reader/reader.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My E-Book Reader"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(),
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
      File docFile = File(result.files[0].path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=>ReaderPage(document : docFile))
      );
    }else{
      //user cancelled selection
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File Selection cancelled")
          )
      );
    }
  }
}
