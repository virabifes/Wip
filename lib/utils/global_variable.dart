import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wip/screens/EventsPage.dart';
import 'package:wip/screens/MyEventsPage.dart';
import 'package:wip/screens/feed_screen.dart';
import 'package:wip/screens/profile_screen.dart';
import 'package:wip/screens/navigation_post_and_event.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  MyEventsPage(
    currentUserId: FirebaseAuth.instance.currentUser!.uid,
  ),
  const NavigatorEP(),
  const EventsListScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
