import 'package:flutter/material.dart';
import '../models/design.dart';

List<Design> UserDesigns = [
  Design(
    text: 'hello',
    fontFamily: 'Arial',
    fontColor: Colors.white,
    backgroundColor: Color(0xFF5CA9FF),
    ownerId: 'dummy-user-1',
    createdAt: DateTime.now().subtract(Duration(minutes: 5)),
  ),
  Design(
    text: 'world',
    fontFamily: 'Georgia',
    fontColor: Colors.white,
    backgroundColor: Color(0xFF2F9928),
    ownerId: 'dummy-user-1',
    createdAt: DateTime.now().subtract(Duration(minutes: 4)),
  ),
  Design(
    text: 'Test',
    fontFamily: 'Courier New',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
    ownerId: 'dummy-user-1',
    createdAt: DateTime.now().subtract(Duration(minutes: 3)),
  ),
  Design(
    text: 'Test2',
    fontFamily: 'Arial',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
    ownerId: 'dummy-user-1',
    createdAt: DateTime.now().subtract(Duration(minutes: 2)),
  ),
  Design(
    text: 'Test3',
    fontFamily: 'Arial',
    fontColor: Colors.black,
    backgroundColor: Color(0xFFFFB7E5),
    ownerId: 'dummy-user-1',
    createdAt: DateTime.now().subtract(Duration(minutes: 1)),
  ),
];
