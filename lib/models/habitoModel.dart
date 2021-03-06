import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:habito/models/category.dart';
import 'package:habito/widgets/text.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class HabitoModel extends Model {
  FirebaseAuth _auth;
  FirebaseUser _user;
  Firestore _firestore;
  List<MyCategory> _myCategoriesList;

  HabitoModel() {
    _auth = FirebaseAuth.instance;
    _firestore = Firestore.instance;
    _myCategoriesList = [];
  }

  //Handle sign ins, outs, and ups
  Future<bool> checkIfSignedIn() async {
    _user = await _auth.currentUser();
    if (_user == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> signOut() async {
    await _auth.signOut();
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (_user != null) {
      return true;
    } else {
      return false;
    }
  }

  //add new category to the firebase
  Future<bool> addNewCategory(MyCategory myCategory) async {
    if (_user != null) {
      myCategory.userId = _user.uid;
      DocumentReference documentReference =
          _firestore.collection("categories").document();
      await documentReference.setData(myCategory.toJson());
      //now add category locally
      myCategory.documentId = documentReference.documentID;
      _myCategoriesList.add(myCategory);
      notifyListeners();
      return true;
    }
    //no user signed in
    return false;
  }

  //warning
  Future<void> neverSatisfied(
      BuildContext context, String title, String description) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: CustomText(
              title,
              color: Colors.black,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CustomText(
                description,
                color: Colors.black,
                textAlign: TextAlign.center,
                fontSize: 14,
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: CustomText(
                  'OK',
                  color: Colors.blue,
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: CustomText('Try Again!'),
            content: CustomText('Could not sign you up at the moment.'),
            actions: <Widget>[
              FlatButton(
                child: CustomText('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }
}
