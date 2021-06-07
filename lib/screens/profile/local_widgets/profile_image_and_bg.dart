import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:provider/provider.dart';

class ProfileImageAndBG extends StatelessWidget {
  final double picRadius;

  ProfileImageAndBG(this.picRadius);

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Container(
      //height: picRadius,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: picRadius * 0.25),
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
            //bottom: picRadius * -0.3,
            bottom: picRadius * 0.2,
            child: InkWell(
              onTap: () {},
              child: ClipOval(
                child: Container(
                  width: picRadius * 2,
                  height: picRadius * 2,
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
    final height = size.height * 0.9;
    var path = Path();
    path.lineTo(0.0, height * 0.65);
    path.quadraticBezierTo(size.width / 2, height, size.width, height * 0.65);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
