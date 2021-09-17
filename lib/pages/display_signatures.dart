import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
// import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:ui' as ui;
import 'package:image/image.dart' as encoder;

class DisplaySignatures extends StatefulWidget {
  List imageList2;
  DisplaySignatures({
    required this.imageList2,
  });
  @override
  _DisplaySignaturesState createState() => _DisplaySignaturesState();
}

class _DisplaySignaturesState extends State<DisplaySignatures> {
  late List imageList;
  bool isLoading = false;
  @override
  void initState() {
    imageList = [];
    getListofImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getESignaturesList(),
    );
  }

  void getListofImages() async {
    final ref = FirebaseStorage.instance.ref();
    ListResult result = await ref.listAll();
    List<Reference> newRef = result.items;
    debugPrint(" Total signature are "+ '${newRef.length}');
    for (int i = 0; i < newRef.length; i++) {
      setState(() {
        isLoading = true;
      });

      newRef[i].getDownloadURL().then((value) {
        imageList.add(value);
        if (i == newRef.length - 1) {
          setState(() {
            isLoading = false;
          });
        }
        debugPrint(" New Reference link is  " + '${value}');
      });
    }
// // no need of the file extension, the name will do fine.
//     var url = await ref.getDownloadURL();
//     print(url);
  }

  Widget getESignaturesList() {
    // ignore: unnecessary_null_comparison
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // } else if (imageList != null && imageList.length == 0 && !isLoading) {
    //   return Container(
    //     alignment: Alignment.center,
    //     child: Text("No Record found"),
    //   );
    // } else if (imageList != null && imageList.length == 0 && isLoading) {
    //   return Center(child: CircularProgressIndicator());
    // }
    return Container(
        child: ListView.builder(
          shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              return Image.network(imageList[index]);
            }));
  }
}
