import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:platzi_trips_app/Place/ui/widgets/card_image.dart';
import 'package:platzi_trips_app/User/bloc/bloc_user.dart';

class CardImageList extends StatelessWidget {

  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {

    userBloc = BlocProvider.of<UserBloc>(context);

    // TODO: implement build
    return Container(
      height: 350.0,
      child: StreamBuilder(
        stream: userBloc.placestream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            case ConnectionState.active:
              return listViewPlaces(userBloc.buildPlaces(snapshot.data.docs));
            case ConnectionState.done:
              return listViewPlaces(userBloc.buildPlaces(snapshot.data.docs));
            case ConnectionState.none:
              return CircularProgressIndicator();
            default:
          }
        },
      )
    );
  }

  Widget listViewPlaces(List<CardImageWithFabIcon> placesCard) {
    return ListView(
      padding: EdgeInsets.all(40.0),
      scrollDirection: Axis.horizontal,
      children: placesCard,
    );
  }

/**/

}