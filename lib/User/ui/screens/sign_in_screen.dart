import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:platzi_trips_app/widgets/gradient_back.dart';
import 'package:platzi_trips_app/widgets/button_green.dart';
import 'package:platzi_trips_app/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:platzi_trips_app/platzi_trips.dart';
import 'package:platzi_trips_app/User/model/user.dart' as userModel;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  UserBloc userBloc;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    // Instanciar el objeto usando el BlocProvider
    screenWidth = MediaQuery.of(context).size.width;
    userBloc = BlocProvider.of(context);
    return _handleCurrentSession();
  }

  Widget _handleCurrentSession() {
    // El StreamBuilder es como un listener que detecta un cambio de estado
    // en la sesión. Si se termina la sesión se dispara el código
    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // snapshot - data - Object User
        if (!snapshot.hasData || snapshot.hasError) {
          return signInGoogleUI();
        } else {
          return PlatziTrips();
        }
      },
    );
  }

  Widget signInGoogleUI() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GradientBack(height: null),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Container(
                    width: screenWidth,
                    child: Text(
                      "Welcome \n This is your Travel App",
                      style: TextStyle(
                          fontSize: 37.0,
                          fontFamily: "Lato",
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),

              ButtonGreen(
                text: "Login with Gmail",
                onPressed: () {
                  userBloc.signOut();
                  userBloc.signIn().then((UserCredential user) {
                    userBloc.updateUserData(userModel.User(
                      uid: user.user.uid,
                      name: user.user.displayName,
                      email: user.user.email,
                      photoURL: user.user.photoURL,
                    ));
                  });
                },
                width: 300.0,
                height: 50.0,
              )
            ],
          )
        ],
      ),
    );
  }
}

