import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:platzi_trips_app/Place/model/place.dart';
import 'package:platzi_trips_app/Place/ui/widgets/card_image.dart';
import 'package:platzi_trips_app/Place/ui/widgets/title_input_location.dart';
import 'package:platzi_trips_app/User/bloc/bloc_user.dart';
import 'package:platzi_trips_app/widgets/button_purple.dart';
import 'package:platzi_trips_app/widgets/gradient_back.dart';
import 'package:platzi_trips_app/widgets/text_input.dart';
import 'package:platzi_trips_app/widgets/title_header.dart';

class AddPlaceScreen extends StatefulWidget {
  File image;

  AddPlaceScreen({Key key, this.image});

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    final _controllerTitlePlace = TextEditingController();
    final _controllerDescriptionPlace = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          GradientBack(
            height: 300.0,
          ),
          Row( // App Bar
            children: [
              Container(
                padding: EdgeInsets.only(top: 25.0, left: 5.0),
                child: SizedBox(
                  height: 45.0,
                  width: 45.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.white,
                      size: 45.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(top: 45.0, left: 20.0, right: 10.0),
                  child: TitleHeader(title: "Add a new place"),
                )
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 120.0, bottom: 20.0),
            child: ListView(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: CardImageWithFabIcon(
                    pathImage: widget.image.path, //"assets/img/sunset.jpeg", // widget.image.path
                    iconData: Icons.camera,
                    width: MediaQuery.of(context).size.width * 0.90,
                    height: 250.0,
                    left: 0.0,
                  ),
                ), // Foto
                Container( // TextField Title
                  margin: EdgeInsets.only(top: 25.0, bottom: 20.0),
                  child: TextInput(
                    hintText: "Title",
                    inputType: null,
                    maxLines: 1,
                    controller: _controllerTitlePlace,
                  )
                ),
                TextInput( // Description
                  hintText: "Description",
                  inputType: TextInputType.multiline,
                  maxLines: 4,
                  controller: _controllerDescriptionPlace,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: TextInputLocation(
                    hintText: "Add Location",
                    iconData: Icons.location_on,
                  ),
                ),
                Container(
                  width: 70.0,
                  child: ButtonPurple(
                    buttonText: "Add Place",
                    onPressed: () {

                      // ID del usuario logueado actualmente
                      userBloc.currentUser().then((User user) async {
                        if(user != null) {
                          String uid = user.uid;
                          String path = "${uid}/${DateTime.now().toString()}.jpg";
                          // 1. Firebase Storage

                          final uploadTask = await userBloc.uploadFile(path, widget.image);
                          if(uploadTask == null){
                            print('Null upload task');
                            return;
                          }

                          TaskSnapshot taskSnapshot = await uploadTask;
                          if(taskSnapshot == null){
                            print('Null task snapshot');
                            return;
                          }

                          final imageUrl = await taskSnapshot.ref.getDownloadURL();
                          if(imageUrl == null){
                            print('Null image URL');
                            return;
                          }

                          print('Image url: $imageUrl');
                          print('name: $_controllerTitlePlace.value.text');
                          print('description: $_controllerDescriptionPlace.value.text');

                          // 2. Cloud Firestore
                          // Place - title, description, url, userOwner, likes
                          userBloc.updatePlaceData(Place(
                              name: _controllerTitlePlace.value.text,
                              description: _controllerDescriptionPlace.value.text,
                              urlImage: imageUrl,
                              likes: 0,
                            )).whenComplete(() {
                              print("TERMINÓ");
                              Navigator.pop(context);
                            }
                          );
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
