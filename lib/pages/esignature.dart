




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

import 'display_signatures.dart';
class ESignature extends StatefulWidget {
  @override
  _ESignatureState createState() => _ESignatureState();
}

class _ESignatureState extends State<ESignature> {
  late File _image;
  bool isUploading = false;
  String _uploadedFileURL = "";
  late List _imageList;
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.blue,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  @override
  void initState() {
    _imageList = [];
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: ListView(
            children: <Widget>[
              Container(
                height: 200,
                child: const Center(
                  child: Text('Please give your ESignature'),
                ),
              ),
              //SIGNATURE CANVAS
              Signature(
                controller: _controller,
                height: 300,
                backgroundColor: Colors.lightBlueAccent,
              ),
              //OK AND CLEAR BUTTONS
              !isUploading?
              Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //SHOW EXPORTED IMAGE IN NEW ROUTE
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.blue,
                      onPressed: () async {
                        if (_controller.isNotEmpty) {

                          final Uint8List? data =
                          await _controller.toPngBytes();
                          // convertToImage();
                         //Image newImage = await _controller.toImage();
                          // pickImage(0);
                        //processImageUpload(data!);
                          processUploadPNG(data);
                        //  _image = await _controller.toImage();
                        //   if (data != null) {
                        //     await Navigator.of(context).push(
                        //       MaterialPageRoute<void>(
                        //         builder: (BuildContext context) {
                        //           return Scaffold(
                        //             appBar: AppBar(),
                        //             body: Center(
                        //               child: Container(
                        //                 color: Colors.grey[300],
                        //                 child: Image.memory(data),
                        //               ),
                        //             ),
                        //           );
                        //         },
                        //       ),
                        //     );
                        //   }
                        }
                      },
                    ),
                    //CLEAR CANVAS
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.clear());
                      },
                    ),
                  ],
                ),
              ):Center(child: CircularProgressIndicator(),),
              Container(
                height: 200,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DisplaySignatures(imageList2: _imageList)));
                    },
                      child:Text("All Signatures from FireStorage")

            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //
  // Future convertToImage() async{
  //   Image newImage;
  //
  //   _controller.toImage().then((value)  {
  //     // newImage = value;
  //     debugPrint("Converted to Image is "+ value.toString());
  //   });
  //   // _controller.t
  // }

  Future pickImage(int type) async {
    final pickedImage = await ImagePicker().pickImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50);
    if (pickedImage != null && pickedImage.path != null) {
      setState(() {

        _image = File(pickedImage.path);
        isUploading = true;
        uploadFile();
      });
    }

    return pickedImage;
  }


  Future processImageUpload(Uint8List data) async {
    // debugPrint(" Data is " '${data.length}');
    // _image = File.fromRawPath(data);
    //
    // ui.Image? obj =  await _controller.toImage();




    var image = await _controller.toImage();

    ByteData? data = await image!.toByteData();
    Uint8List listData = data!.buffer.asUint8List();

    final FirebaseStorage storage = FirebaseStorage.instance;
    final String picture = "${DateTime.now().millisecondsSinceEpoch.toString()}.png";
  //  StorageUploadTask task = storage.ref().child(picture).putData(listData);

    FirebaseStorage storageReference = FirebaseStorage.instance;
    UploadTask ref =
    storageReference.ref().child(picture).putData(listData);
    //UploadTask uploadTask = ref.putFile(_image);
    ref.then((value) {
      debugPrint(" Uploaded picture"+ '${value.ref.name}');
    });
   // debugPrint(" Reference is "+ ref.the)
   // debugPrint(" Object here "+ '${obj}');
   //  debugPrint(" Image path is  "+ '${File.fromRawPath(data).path}');
   //  debugPrint(" Image path absolute  "+ '${File.fromRawPath(data).absolute}');
   //  debugPrint(" Image is"+ '${_image.existsSync()}');
   // uploadFile();
    if(_image.existsSync()){

      uploadFile();
    }else{

      debugPrint(" Image not sync to proceed");
    }

  }

  Future processUploadPNG(Uint8List? dataUnit) async{
    setState(() {

      isUploading = true;
    });

    var image = await _controller.toImage();

//Store image dimensions for later
    int height = image!.height;
    int width = image.width;

    ByteData? data = await image.toByteData();
    Uint8List listData = data!.buffer.asUint8List();

    encoder.Image toEncodeImage = encoder.Image.fromBytes(width, height, listData);
    encoder.JpegEncoder jpgEncoder = encoder.JpegEncoder();

    List<int> encodedImage = jpgEncoder.encodeImage(toEncodeImage);

    final FirebaseStorage storage = FirebaseStorage.instance;
    final String picture = "${DateTime.now().millisecondsSinceEpoch.toString()}.png";

    FirebaseStorage storageReference = FirebaseStorage.instance;
    UploadTask ref =
    storageReference.ref().child(picture).putData(Uint8List.fromList(encodedImage));
    //UploadTask uploadTask = ref.putFile(_image);
    ref.then((value) {
      debugPrint(" Uploaded picture name is "+ '${value.ref.name}');
      debugPrint(" Full Path is "+ '${value.ref.fullPath}');
      value.ref.getDownloadURL().then((download) async {
        debugPrint(" Exact Download URL is "+ '${download}');
        if (dataUnit != null) {
          setState(() {
            isUploading= false;
          });

          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: Container(
                      color: Colors.grey[300],
                      child: Image.memory(dataUnit),
                    ),
                  ),
                );
              },
            ),
          );
        }

      });

    //  value.ref.getDownloadURL().then()
    });

  //  getListofImages();
  }

  void getListofImages() async{

    final ref = FirebaseStorage.instance.ref();
    ListResult result =await ref.listAll();
    List<Reference> newRef = result.items;

    for(int i=0;i<newRef.length;i++){
      newRef[i].getDownloadURL().then((value) {
        _imageList.add(value);
        debugPrint(" New Reference link is  "+ '${value}');
      });

    }
// // no need of the file extension, the name will do fine.
//     var url = await ref.getDownloadURL();
//     print(url);
  }

  Widget getESignaturesList(){

    // ignore: unnecessary_null_comparison
    if(_imageList==null){
      return CircularProgressIndicator();
    }else if(_imageList!=null&&_imageList.length==0){
      return Container(
        alignment: Alignment.center,
        child: Text("No Record found"),
      );
    }
    return Container(
      child:ListView.builder(
          itemCount: _imageList.length,
          itemBuilder: (context, index) {
              return Image.network(_imageList[index]);
          })
    );
  }



  Future uploadFile() async {
    print("In Upload file");

    FirebaseStorage storageReference = FirebaseStorage.instance;
    Reference ref =
    storageReference.ref().child('esignature/${Path.basename(_image.path)}}');
    UploadTask uploadTask = ref.putFile(_image);

    uploadTask.then((res) {
      print('File Uploaded');
      res.ref.getDownloadURL().then((fileURL) {
        setState(() {
          _uploadedFileURL = fileURL;
          isUploading = false;
          print("Uploaded URL is " + '$_uploadedFileURL');
          // messageController.text = fileURL;
          // sendMessage(1);
          //  Fluttertoast.showToast(msg: 'Picture uploaded Successfully!');
          // _key.currentState.showSnackBar(
          //     SnackBar(content: Text("Picture uploaded Successfully!")));
        });
      });
    });
  }

}
