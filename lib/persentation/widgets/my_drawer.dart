import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/constants/colors.dart';
import 'package:task/constants/strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../business_logic/cubit/phone_auth/phone_auth_cubit.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);
  final PhoneAuthCubit _phoneAuthCubit = PhoneAuthCubit();

  Widget _buildDrawerHeader(context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(70, 10, 70, 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.blue[100],
          ),
          child: Image.asset('assets/images/esraa.jpeg', fit: BoxFit.cover),
        ),
        const Text('Esraa Helaly',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        BlocProvider<PhoneAuthCubit>(
          create: ((context) => _phoneAuthCubit),
          child: Text(
            "${_phoneAuthCubit.getLoggedInUser().phoneNumber}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerListItem(
      {required IconData leadingIcon,
      required String title,
      Widget? trailing,
      Function()? onTap,
      Color? color}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      leading: Icon(leadingIcon, color: color ?? MyColors.blue),
      trailing:
          trailing ?? Icon(Icons.arrow_right, color: color ?? MyColors.blue),
      onTap: onTap,
    );
  }

  Widget _buildDrawerListItemDivider() {
    return const Divider(
      height: 0,
      indent: 18,
      thickness: 1,
      endIndent: 24,
    );
  }

  void _launchURL(Uri url) async {
    await canLaunchUrl(url)
        ? await launchUrl(url)
        : throw 'couldn\'t launch url';
  }

  Widget _buildIcon({required IconData icon, required Uri url}) {
    return InkWell(
      onTap: (() => _launchURL(url)),
      child: Icon(icon, size: 35, color: MyColors.blue),
    );
  }

  Widget _buildSocialMediaIcons() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: [
          _buildIcon(
              icon: FontAwesomeIcons.facebook,
              url: Uri.parse(
                  'https://www.facebook.com/profile.php?id=100005086772781')),
          const SizedBox(width: 15),
          _buildIcon(
              icon: FontAwesomeIcons.linkedinIn,
              url: Uri.parse(
                  'https://www.linkedin.com/in/esraa-helaly-573548175/')),
          const SizedBox(width: 20),
          _buildIcon(
              icon: FontAwesomeIcons.instagram,
              url:
                  Uri.parse('https://www.instagram.com/helalyesraa144/?hl=en')),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 300,
            child: DrawerHeader(
              child: _buildDrawerHeader(context),
              decoration: BoxDecoration(color: Colors.blue[100]),
            ),
          ),
          _buildDrawerListItem(leadingIcon: Icons.person, title: 'My Profile'),
          _buildDrawerListItemDivider(),
          _buildDrawerListItem(
              leadingIcon: Icons.history, title: 'History', onTap: () {}),
          _buildDrawerListItemDivider(),

          //TODO::navigate to history places

          _buildDrawerListItem(leadingIcon: Icons.settings, title: 'Settings'),
          _buildDrawerListItemDivider(),
          _buildDrawerListItem(leadingIcon: Icons.help, title: 'Help'),
          BlocProvider<PhoneAuthCubit>(
            create: (context) => _phoneAuthCubit,
            child: _buildDrawerListItem(
              leadingIcon: Icons.logout,
              title: 'LogOut',
              onTap: () async {
                await _phoneAuthCubit.logOut();
                Navigator.of(context).pushReplacementNamed(loginScreen);
              },
              color: Colors.red,
              trailing: const SizedBox(),
            ),
          ),
          const SizedBox(height: 100),
          const ListTile(leading: Text('Follow Us')),
          _buildSocialMediaIcons(),
        ],
      ),
    );
  }
}
