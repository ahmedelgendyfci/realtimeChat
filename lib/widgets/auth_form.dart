import 'dart:developer';
import 'dart:io';

import 'package:chat_app2/pickers/image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this._isLogin);

  final bool _isLogin;

  final void Function(dynamic authData, bool isLogin, BuildContext context)
      submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLogin = true;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  var _userImageFile;

  void imagePickFn(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    bool isValid = _formKey.currentState!.validate();
    // ignore: unnecessary_null_comparison

    if (_userImageFile == null && !_isLogin) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Please Pick An Image!')));
      return;
    }
    if (isValid) {
      FocusScope.of(context).unfocus();
      _userEmail = _emailController.text;
      _userName = _usernameController.text;
      _userPassword = _passwordController.text;
      login() {
        return {
          'email': _userEmail.trim(),
          'password': _userPassword.trim(),
        };
      }

      signUp() {
        return {
          'email': _userEmail.trim(),
          'password': _userPassword.trim(),
          'username': _userName.trim(),
          'imageFile': _userImageFile,
        };
      }

      if (_isLogin) {
        widget.submitFn(login(), _isLogin, context);
      } else {
        widget.submitFn(signUp(), _isLogin, context);
      }
      // submit function
      // widget.submitFn(
      //   _userEmail.trim(),
      //   _userName.trim(),
      //   _userPassword.trim(),
      //   _userImageFile,
      //   _isLogin,
      //   context,
      // );

      // _emailController.clear();
      // _usernameController.clear();
      // _passwordController.clear();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!_isLogin) ImagePickerW(imagePickFn),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      log(value.toString());
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      _emailController.text = value;
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                    ),
                  ),
                  if (!_isLogin)
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 12),
                  RaisedButton(
                    child: widget._isLogin
                        ? CircularProgressIndicator()
                        : Text(_isLogin ? 'Login' : 'Signup'),
                    onPressed: _trySubmit,
                  ),
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text(_isLogin
                        ? 'Create new account'
                        : 'I already have an account'),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
