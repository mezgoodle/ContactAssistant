import 'package:go_router/go_router.dart';
import 'package:contact_assistant/presentation/screens/home_screen.dart';
import 'package:contact_assistant/presentation/screens/add_edit_contact_screen.dart';
import 'package:contact_assistant/presentation/screens/contact_detail_screen.dart';
import 'package:contact_assistant/presentation/screens/settings_screen.dart';
import 'package:contact_assistant/presentation/screens/networking_guide_screen.dart';
import 'package:contact_assistant/presentation/screens/icebreaker_screen.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/core/services/ai_notes_service.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/icebreaker',
      builder: (context, state) => const IcebreakerScreen(),
    ),
    GoRoute(
      path: '/add_contact',
      builder: (context, state) => const AddEditContactScreen(),
    ),
    GoRoute(
      path: '/edit_contact',
      builder: (context, state) {
        final contact = state.extra;
        if (contact is! Contact) {
          return const Scaffold(
            body: Center(
                child: Text('Invalid navigation: Contact data required')),
          );
        }
        return AddEditContactScreen(contact: contact);
      },
    ),
    GoRoute(
      path: '/contact/:id',
      builder: (context, state) {
        final contact = state.extra;
        if (contact is! Contact) {
          return const Scaffold(
            body: Center(
                child: Text('Invalid navigation: Contact data required')),
          );
        }
        return ContactDetailScreen(contact: contact);
      },
    ),
    GoRoute(
      path: '/networking_guide',
      builder: (context, state) {
        final extras = state.extra;
        if (extras is! Map<String, dynamic>) {
          return const Scaffold(
            body: Center(
                child: Text(
                    'Invalid navigation: Contact and Profile data required')),
          );
        }
        final contact = extras['contact'];
        final profile = extras['profile'];
        if (contact is! Contact || profile is! FerrazziProfile) {
          return const Scaffold(
            body: Center(
              child:
                  Text('Invalid navigation: Contact and Profile data required'),
            ),
          );
        }
        return NetworkingGuideScreen(
          contact: contact,
          profile: profile,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
