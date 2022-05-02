// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:task/constants/strings.dart';

import '../../business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import '../../constants/colors.dart';
import '../widgets/show_progress_indecator.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  final phoneNumber;
  late String otpCode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
          child: Column(
            children: [
              Text(
                'Verify your phone number $phoneNumber',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 88),
              _buildPinCodeFields(context),
              const SizedBox(height: 60),
              _buildVrifyButton(context),
              _buildPhoneVerificationBloc(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinCodeFields(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      autoFocus: true,
      cursorColor: Colors.black,
      keyboardType: TextInputType.number,
      length: 6,
      obscureText: false,
      animationType: AnimationType.scale,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        borderWidth: 1,
        activeColor: MyColors.blue,
        inactiveColor: MyColors.blue,
        inactiveFillColor: Colors.white,
        activeFillColor: MyColors.lightBlue,
        selectedColor: MyColors.blue,
        selectedFillColor: Colors.white,
      ),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.white,
      enableActiveFill: true,
      onCompleted: (submitedCode) {
        otpCode = submitedCode;
      },
      onChanged: (value) {},
    );
  }

  Widget _buildVrifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _login(context);
        },
        child: const Text('Next'),
      ),
    );
  }

  void _login(BuildContext context) {
    BlocProvider.of<PhoneAuthCubit>(context).submitOTP(otpCode);
  }

  Widget _buildPhoneVerificationBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is Loading) {
          showProgressIndicator(context);
        }

        if (state is PhoneOTPVerified) {
          Navigator.pop(context);
          Navigator.of(context).pushReplacementNamed(mapScreen);
        }

        if (state is ErrorOccurred) {
          //Navigator.pop(context);
          String errorMsg = (state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.black,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(),
    );
  }
}
