import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rrr/dogu/palette.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const CustomBottomNavigationBar(this.navigationShell, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: ThemeData(
          useMaterial3: false,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SizedBox(
          height: 80,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(index),
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/svgs/bottom_navigation_bar/sound_detection_dog_barking.svg',
                  width: 25,
                  color:
                      navigationShell.currentIndex == 0
                          ? Palette.iconPrimary
                          : Palette.iconSecondary,
                ),
                label: '번역',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/svgs/bottom_navigation_bar/pets.svg',
                  width: 25,
                  color:
                      navigationShell.currentIndex == 1
                          ? Palette.iconPrimary
                          : Palette.iconSecondary,
                ),
                label: '프로필',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
