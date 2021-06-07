import 'package:flutter/material.dart';
import 'package:gangbook/screens/profile/local_widgets/profile_image_and_bg.dart';

class CustomSliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final TabBar tabBar;
  final Widget leading;
  final Widget title;

  CustomSliverAppBar(
      {this.expandedHeight, this.leading, this.title, this.tabBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        Opacity(
          opacity: disappear(shrinkOffset),
          child: ProfileImageAndBG(expandedHeight),
        ),
        Opacity(
          opacity: appear(shrinkOffset),
          child: AppBar(
            leading: leading,
            title: title,
            bottom: tabBar,
          ),
        ),
      ],
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
