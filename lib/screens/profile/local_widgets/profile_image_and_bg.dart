import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class ProfileImageAndBG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final picRaduis = screenSize.width * 0.25;
    final userState = Provider.of<UserState>(context);

    return Container(
      height: screenSize.height * 0.25,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: picRaduis * 0.25),
      child: Stack(
        alignment: Alignment.bottomCenter,
        overflow: Overflow.visible,
        children: [
          ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          Positioned(
            bottom: picRaduis * -0.3,
            child: InkWell(
              onTap: () {},
              child: ClipOval(
                child: Container(
                  width: picRaduis * 2,
                  height: picRaduis * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      userState.user.profileImageUrl == null
                          ? Image.asset(
                              'assets/images/person_placeholder.png',
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            )
                          : FadeInImage(
                              placeholder: AssetImage(
                                  'assets/images/person_placeholder.png'),
                              image:
                                  NetworkImage(userState.user.profileImageUrl),
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.65);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.65);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
