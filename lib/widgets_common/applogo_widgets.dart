import '../consts/consts.dart';

Widget appLogoWidget() {
  //using velocity here
  return Image.asset(
    icAppLogo,
  ).box.white.size(90, 90).padding(EdgeInsets.all(8)).rounded.make();
}
