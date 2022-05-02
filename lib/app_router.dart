import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/business_logic/cubit/maps/maps_cubit.dart';
import 'package:task/data/repository/maps_repo.dart';

import 'package:task/persentation/screens/Login_screen.dart';
import 'package:task/persentation/screens/map_screen.dart';

import 'business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'constants/strings.dart';
import 'data/web_services/places_web_services.dart';
import 'persentation/screens/otp_screen.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;

  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => MapsCubit(MapsRepo(PlacesWebServices())),
            child: const MapScreen(),
          ),
        );
      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: LoginScreen(),
          ),
        );

      case otpScreen:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: OtpScreen(phoneNumber: phoneNumber),
          ),
        );
    }
    return null;
  }
}
