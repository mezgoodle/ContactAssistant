// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isarServiceHash() => r'166434f468bdfc9be39ec3c837e910cc39d4268e';

/// See also [isarService].
@ProviderFor(isarService)
final isarServiceProvider = AutoDisposeProvider<IsarService>.internal(
  isarService,
  name: r'isarServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isarServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsarServiceRef = AutoDisposeProviderRef<IsarService>;
String _$contactsHash() => r'9ce566dc2f25fcf2597cf5b40b64fb3abd806e58';

/// See also [Contacts].
@ProviderFor(Contacts)
final contactsProvider =
    AutoDisposeStreamNotifierProvider<Contacts, List<Contact>>.internal(
  Contacts.new,
  name: r'contactsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$contactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Contacts = AutoDisposeStreamNotifier<List<Contact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
