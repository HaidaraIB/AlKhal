import 'dart:convert';

import 'package:alkhal/cubit/user/user_cubit.dart';
import 'package:alkhal/services/database_helper.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is LoginSuccess || state is ConfirmRestoreDb) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تسجيل الدخول بنجاح',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
          if (state is ConfirmRestoreDb) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'تأكيد الاستعادة',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                  content: const Text(
                    'تم العثور على نسخة احتياطية هل تريد استعادتها؟\nسيؤدي الإلغاء إلى خسارة النسخة الاحتياطية',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed("/home");
                      },
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () async {
                        bool res = await DatabaseHelper.restoreRemoteDatabase(
                          base64Decode(state.dbAsBytes),
                        );
                        String msg = "";
                        if (res) {
                          msg = "تمت استعادة البيانات بنجاح";
                        } else {
                          msg = "لم يتم العثور على نسخة احتياطية";
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                msg,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          );
                        }
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed("/home");
                        }
                      },
                      child: const Text('استعادة'),
                    ),
                  ],
                );
              },
            );
          } else {
            Navigator.of(context).pushReplacementNamed("/home");
          }
        } else if (state is LoginFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'حصل خطأ أثناء تسجيل الدخول يرجى إعادة المحاولة',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        } else if (state is NoInternet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تحقق من اتصالك بالإنترنت',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                _inputField(context, state),
                _logInButton(state),
                _signUp(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(context) {
    return const Column(
      children: [
        Text(
          "مرحباً بعودتك",
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context, state) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: validateUsername,
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "اسم المستخدم",
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.purple.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(Icons.person),
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: validatePassword,
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: "كلمة المرور",
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.purple.withOpacity(0.1),
                  filled: true,
                  prefixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() {
                      _passwordVisible = !_passwordVisible;
                    }),
                  ),
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  errorMaxLines: 3,
                ),
                obscureText: !_passwordVisible,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _logInButton(state) {
    return state is Loading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          )
        : ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await context.read<UserCubit>().login(
                      _usernameController.text,
                      _passwordController.text,
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.purple,
            ),
            child: const Text(
              "تسجيل الدخول",
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
  }

  Widget _signUp(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/sign_up'),
          child: const Text(
            "اشترك الآن",
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.purple),
          ),
        ),
        const Text(
          "ليس لديك حساب؟",
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
