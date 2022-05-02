// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import '../../constants/strings.dart';
import '../widgets/show_progress_indecator.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final GlobalKey<FormState> _phoneFormKey = GlobalKey();

  late String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _phoneFormKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Enter Your Mobile Number ',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
                _buildPhoneFormField(),
                const SizedBox(height: 70),
                _buildNextButton(context),
                _buildPhoneNumberSubmitedBloc(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _register(context);
        },
        child: const Text('Next'),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    if (!_phoneFormKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    } else {
      Navigator.pop(context);
      _phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(phoneNumber);
    }
  }

  Widget _buildPhoneFormField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: TextFormField(
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '+20',
          prefixIcon: Icon(Icons.phone),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your phone number';
          } else if (value.length < 11) {
            return 'enter valid number';
          }
          return null;
        },
        onSaved: (value) {
          phoneNumber = value!;
        },
      ),
    );
  }

  Widget _buildPhoneNumberSubmitedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is Loading) {
          showProgressIndicator(context);
        }

        if (state is PhoneNumberSubmited) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpScreen, arguments: phoneNumber);
        }

        if (state is ErrorOccurred) {
          Navigator.pop(context);
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
