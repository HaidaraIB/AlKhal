import 'package:alkhal/cubit/user/user_cubit.dart';
import 'package:alkhal/models/user.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: User.userInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _usernameController.text = snapshot.data!['username'];
          _emailController.text = snapshot.data!['email'];
          return BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserInfoUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "تم تعديل معلومات الحساب بنجاح",
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              } else if (state is NoInternet) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "تحقق من اتصالك بالإنترنت",
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              } else if (state is UpdateUserInfoFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "حصل خطأ أثناء تعديل معلومات حسابك",
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text("معلومات الحساب"),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await User.clearInfo();
                      if (context.mounted) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).pushReplacementNamed("/sign_up");
                      }
                    },
                    icon: const Icon(Icons.logout),
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _userInfoForm(snapshot),
                      BlocBuilder<UserCubit, UserState>(
                        bloc: BlocProvider.of<UserCubit>(context),
                        builder: (context, state) {
                          return _editInfoButton(state, snapshot);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            ),
          );
        }
      },
    );
  }

  Widget _userInfoForm(AsyncSnapshot<Map> snapshot) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (_newPasswordController.text.isEmpty &&
                  _oldPasswordController.text.isEmpty &&
                  _usernameController.text == snapshot.data!['username'] &&
                  _emailController.text == snapshot.data!['email']) {
                return "الرجاء تعديل أحد الحقول";
              }
              return validateUsername(value);
            },
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
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (_newPasswordController.text.isEmpty &&
                  _oldPasswordController.text.isEmpty &&
                  _usernameController.text == snapshot.data!['username'] &&
                  _emailController.text == snapshot.data!['email']) {
                return "الرجاء تعديل أحد الحقول";
              }
              return validateEmail(value);
            },
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "الإيميل",
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.email),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (_newPasswordController.text.isEmpty &&
                  _oldPasswordController.text.isEmpty &&
                  _usernameController.text == snapshot.data!['username'] &&
                  _emailController.text == snapshot.data!['email']) {
                return "الرجاء تعديل أحد الحقول";
              }
              return validateOldPassword(value, snapshot.data!['password']);
            },
            controller: _oldPasswordController,
            decoration: InputDecoration(
              hintText: "كلمة المرور القديمة",
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: IconButton(
                icon: Icon(
                  _oldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() {
                  _oldPasswordVisible = !_oldPasswordVisible;
                }),
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              errorMaxLines: 3,
            ),
            obscureText: !_oldPasswordVisible,
          ),
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              if (_newPasswordController.text.isEmpty &&
                  _oldPasswordController.text.isEmpty &&
                  _usernameController.text == snapshot.data!['username'] &&
                  _emailController.text == snapshot.data!['email']) {
                return "الرجاء تعديل أحد الحقول";
              }
              return validateNewPassword(value);
            },
            controller: _newPasswordController,
            decoration: InputDecoration(
              hintText: "كلمة المرور الجديدة",
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: IconButton(
                icon: Icon(
                  _newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() {
                  _newPasswordVisible = !_newPasswordVisible;
                }),
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              errorMaxLines: 3,
            ),
            obscureText: !_newPasswordVisible,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _editInfoButton(UserState state, AsyncSnapshot<Map> snapshot) {
    return Container(
      padding: const EdgeInsets.only(top: 3, left: 3),
      child: state is Loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            )
          : ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await context.read<UserCubit>().updateUserInfo(
                        id: snapshot.data!['id'],
                        username: _usernameController.text,
                        email: _emailController.text,
                        password: _newPasswordController.text.isEmpty
                            ? snapshot.data!['password']
                            : _newPasswordController.text,
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                "تعديل الحساب",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
