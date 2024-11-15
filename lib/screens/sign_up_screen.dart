import 'package:alkhal/cubit/user/user_cubit.dart';
import 'package:alkhal/models/user.dart';
import 'package:alkhal/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          Navigator.of(context).pushReplacementNamed("/home");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إنشاء حساب بنجاح',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        } else if (state is SignUpFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'حصل خطأ أثناء إنشاء حسابك يرجى إعادة المحاولة',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        } else if (state is NoInternet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تحقق من اتصالك بالأنترنت',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: MediaQuery.of(context).size.height - 50,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _header(),
                  _signUpForm(),
                  _signUpButton(state),
                  _logIn(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    return const Column(
      children: <Widget>[
        SizedBox(height: 60.0),
        Text(
          "إنشاء حساب",
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _signUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
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
          const SizedBox(height: 20),
          TextFormField(
            validator: validateEmail,
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
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
          const SizedBox(height: 20),
          TextFormField(
            validator: (value) {
              return validateConfirmPassword(
                value,
                _passwordController.text,
              );
            },
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              hintText: "تأكيد كلمة المرور",
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.purple.withOpacity(0.1),
              filled: true,
              prefixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
    );
  }

  Widget _signUpButton(state) {
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
                  User user = User(
                    email: _emailController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                  );
                  await context.read<UserCubit>().signUp(user);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                "اشترك الآن",
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

  Widget _logIn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            "تسجيل الدخول",
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.purple),
          ),
        ),
        const Text(
          "لديك حساب مسبقاً؟",
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
