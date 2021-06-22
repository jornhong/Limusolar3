// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `PVMobileSuite`
  String get App_Name {
    return Intl.message(
      'PVMobileSuite',
      name: 'App_Name',
      desc: '',
      args: [],
    );
  }

  /// `Active Monitor`
  String get Active_Monitor {
    return Intl.message(
      'Active Monitor',
      name: 'Active_Monitor',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get Dashboard {
    return Intl.message(
      'Dashboard',
      name: 'Dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Battery Options`
  String get Battery_Options {
    return Intl.message(
      'Battery Options',
      name: 'Battery_Options',
      desc: '',
      args: [],
    );
  }

  /// `Profiles`
  String get Profiles {
    return Intl.message(
      'Profiles',
      name: 'Profiles',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get Options {
    return Intl.message(
      'Options',
      name: 'Options',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get Language {
    return Intl.message(
      'Language',
      name: 'Language',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get Follow_system {
    return Intl.message(
      'Follow system',
      name: 'Follow_system',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get English {
    return Intl.message(
      'English',
      name: 'English',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get French {
    return Intl.message(
      'French',
      name: 'French',
      desc: '',
      args: [],
    );
  }

  /// `German`
  String get German {
    return Intl.message(
      'German',
      name: 'German',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get CANCEL {
    return Intl.message(
      'CANCEL',
      name: 'CANCEL',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get OK {
    return Intl.message(
      'OK',
      name: 'OK',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get Tips {
    return Intl.message(
      'Tips',
      name: 'Tips',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get Privacy {
    return Intl.message(
      'Privacy',
      name: 'Privacy',
      desc: '',
      args: [],
    );
  }

  /// `Solar Controller Manager For Mobile Phone`
  String get Solar_Controller_Manager_For_Mobile_Phone {
    return Intl.message(
      'Solar Controller Manager For Mobile Phone',
      name: 'Solar_Controller_Manager_For_Mobile_Phone',
      desc: '',
      args: [],
    );
  }

  /// `Detail`
  String get Detail {
    return Intl.message(
      'Detail',
      name: 'Detail',
      desc: '',
      args: [],
    );
  }

  /// `Device Info`
  String get Device_Info {
    return Intl.message(
      'Device Info',
      name: 'Device_Info',
      desc: '',
      args: [],
    );
  }

  /// `Charge Hist`
  String get Charge_Hist {
    return Intl.message(
      'Charge Hist',
      name: 'Charge_Hist',
      desc: '',
      args: [],
    );
  }

  /// `System Voltage`
  String get System_Voltage {
    return Intl.message(
      'System Voltage',
      name: 'System_Voltage',
      desc: '',
      args: [],
    );
  }

  /// `SEALED`
  String get SEALED {
    return Intl.message(
      'SEALED',
      name: 'SEALED',
      desc: '',
      args: [],
    );
  }

  /// `GEL`
  String get GEL {
    return Intl.message(
      'GEL',
      name: 'GEL',
      desc: '',
      args: [],
    );
  }

  /// `FLOODED`
  String get FLOODED {
    return Intl.message(
      'FLOODED',
      name: 'FLOODED',
      desc: '',
      args: [],
    );
  }

  /// `LIFOS`
  String get LIFOS {
    return Intl.message(
      'LIFOS',
      name: 'LIFOS',
      desc: '',
      args: [],
    );
  }

  /// `CUSTOM`
  String get CUSTOM {
    return Intl.message(
      'CUSTOM',
      name: 'CUSTOM',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get Read {
    return Intl.message(
      'Read',
      name: 'Read',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get Send {
    return Intl.message(
      'Send',
      name: 'Send',
      desc: '',
      args: [],
    );
  }

  /// `Remote Controller Not Connected!`
  String get Remote_Controller_Not_Connected {
    return Intl.message(
      'Remote Controller Not Connected!',
      name: 'Remote_Controller_Not_Connected',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get Error {
    return Intl.message(
      'Error',
      name: 'Error',
      desc: '',
      args: [],
    );
  }

  /// `System Voltage is Auto, CUSTOM param is not allowed!`
  String get System_Voltage_is_Auto_CUSTOM_param_is_not_allowed {
    return Intl.message(
      'System Voltage is Auto, CUSTOM param is not allowed!',
      name: 'System_Voltage_is_Auto_CUSTOM_param_is_not_allowed',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth is not enabled. Bluetooth is required to connect to the device, please enable it.`
  String get Bluetooth_is_not_enabled {
    return Intl.message(
      'Bluetooth is not enabled. Bluetooth is required to connect to the device, please enable it.',
      name: 'Bluetooth_is_not_enabled',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth is not enabled. \nBluetooth is required to connect to the device, enable now?`
  String get Bluetooth_is_disabled_enable_now {
    return Intl.message(
      'Bluetooth is not enabled. \nBluetooth is required to connect to the device, enable now?',
      name: 'Bluetooth_is_disabled_enable_now',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth Connected`
  String get Bluetooth_Connected {
    return Intl.message(
      'Bluetooth Connected',
      name: 'Bluetooth_Connected',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get Connect {
    return Intl.message(
      'Connect',
      name: 'Connect',
      desc: '',
      args: [],
    );
  }

  /// `CONNECT`
  String get CONNECT {
    return Intl.message(
      'CONNECT',
      name: 'CONNECT',
      desc: '',
      args: [],
    );
  }

  /// `DISCONNECT`
  String get DISCONNECT {
    return Intl.message(
      'DISCONNECT',
      name: 'DISCONNECT',
      desc: '',
      args: [],
    );
  }

  /// `Scanning devices...`
  String get Scanning_devices {
    return Intl.message(
      'Scanning devices...',
      name: 'Scanning_devices',
      desc: '',
      args: [],
    );
  }

  /// `Connect failed!`
  String get Connect_Failed {
    return Intl.message(
      'Connect failed!',
      name: 'Connect_Failed',
      desc: '',
      args: [],
    );
  }

  /// `Connecting...`
  String get Connecting {
    return Intl.message(
      'Connecting...',
      name: 'Connecting',
      desc: '',
      args: [],
    );
  }

  /// `Device connected`
  String get Device_Connected {
    return Intl.message(
      'Device connected',
      name: 'Device_Connected',
      desc: '',
      args: [],
    );
  }

  /// `Device not connected`
  String get Device_Not_Connected {
    return Intl.message(
      'Device not connected',
      name: 'Device_Not_Connected',
      desc: '',
      args: [],
    );
  }

  /// `Authentication failed!`
  String get Authentication_Failed {
    return Intl.message(
      'Authentication failed!',
      name: 'Authentication_Failed',
      desc: '',
      args: [],
    );
  }

  /// `Access`
  String get Access {
    return Intl.message(
      'Access',
      name: 'Access',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get Name {
    return Intl.message(
      'Name',
      name: 'Name',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get Password {
    return Intl.message(
      'Password',
      name: 'Password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get Confirm_Password {
    return Intl.message(
      'Confirm Password',
      name: 'Confirm_Password',
      desc: '',
      args: [],
    );
  }

  /// `Remember Password?`
  String get Remember_Password {
    return Intl.message(
      'Remember Password?',
      name: 'Remember_Password',
      desc: '',
      args: [],
    );
  }

  /// `Session`
  String get Session {
    return Intl.message(
      'Session',
      name: 'Session',
      desc: '',
      args: [],
    );
  }

  /// `Length`
  String get Length {
    return Intl.message(
      'Length',
      name: 'Length',
      desc: '',
      args: [],
    );
  }

  /// `Tx`
  String get Tx {
    return Intl.message(
      'Tx',
      name: 'Tx',
      desc: '',
      args: [],
    );
  }

  /// `Rx`
  String get Rx {
    return Intl.message(
      'Rx',
      name: 'Rx',
      desc: '',
      args: [],
    );
  }

  /// `Tx Error`
  String get Tx_Error {
    return Intl.message(
      'Tx Error',
      name: 'Tx_Error',
      desc: '',
      args: [],
    );
  }

  /// `Rx Error`
  String get Rx_Error {
    return Intl.message(
      'Rx Error',
      name: 'Rx_Error',
      desc: '',
      args: [],
    );
  }

  /// `BAT1`
  String get BAT1 {
    return Intl.message(
      'BAT1',
      name: 'BAT1',
      desc: '',
      args: [],
    );
  }

  /// `BAT2`
  String get BAT2 {
    return Intl.message(
      'BAT2',
      name: 'BAT2',
      desc: '',
      args: [],
    );
  }

  /// `Save Current`
  String get SaveCurrent {
    return Intl.message(
      'Save Current',
      name: 'SaveCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message(
      'Delete',
      name: 'Delete',
      desc: '',
      args: [],
    );
  }

  /// `Load`
  String get Load {
    return Intl.message(
      'Load',
      name: 'Load',
      desc: '',
      args: [],
    );
  }

  /// `Failure`
  String get Failure {
    return Intl.message(
      'Failure',
      name: 'Failure',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get Success {
    return Intl.message(
      'Success',
      name: 'Success',
      desc: '',
      args: [],
    );
  }

  /// `Save Current Configuration`
  String get Save_Current_Configuration {
    return Intl.message(
      'Save Current Configuration',
      name: 'Save_Current_Configuration',
      desc: '',
      args: [],
    );
  }

  /// `This profile cannot be deleted!`
  String get This_profile_cannot_be_deleted {
    return Intl.message(
      'This profile cannot be deleted!',
      name: 'This_profile_cannot_be_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Sure you want to delete?`
  String get Sure_you_want_to_delete {
    return Intl.message(
      'Sure you want to delete?',
      name: 'Sure_you_want_to_delete',
      desc: '',
      args: [],
    );
  }

  /// `{profile} is damaged!`
  String profile_is_damaged(Object profile) {
    return Intl.message(
      '$profile is damaged!',
      name: 'profile_is_damaged',
      desc: '',
      args: [profile],
    );
  }

  /// `{profile} is loaded!`
  String profile_is_loaded(Object profile) {
    return Intl.message(
      '$profile is loaded!',
      name: 'profile_is_loaded',
      desc: '',
      args: [profile],
    );
  }

  /// `Edit Name or Password`
  String get Edit_Name_or_Password {
    return Intl.message(
      'Edit Name or Password',
      name: 'Edit_Name_or_Password',
      desc: '',
      args: [],
    );
  }

  /// `Change Device Name`
  String get Change_Device_Name {
    return Intl.message(
      'Change Device Name',
      name: 'Change_Device_Name',
      desc: '',
      args: [],
    );
  }

  /// `Changing the device name will reset the access password to the device name.`
  String get Change_Device_Name_summary {
    return Intl.message(
      'Changing the device name will reset the access password to the device name.',
      name: 'Change_Device_Name_summary',
      desc: '',
      args: [],
    );
  }

  /// `Change Access Password`
  String get Change_Access_Password {
    return Intl.message(
      'Change Access Password',
      name: 'Change_Access_Password',
      desc: '',
      args: [],
    );
  }

  /// `Lost password will cause the device to be unable to connect.`
  String get Change_Access_Password_summary {
    return Intl.message(
      'Lost password will cause the device to be unable to connect.',
      name: 'Change_Access_Password_summary',
      desc: '',
      args: [],
    );
  }

  /// `Name must be 6 digits or characters`
  String get Name_must_be_6_digits_or_characters {
    return Intl.message(
      'Name must be 6 digits or characters',
      name: 'Name_must_be_6_digits_or_characters',
      desc: '',
      args: [],
    );
  }

  /// `Name can't be empty!`
  String get Name_cant_be_empty {
    return Intl.message(
      'Name can\'t be empty!',
      name: 'Name_cant_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `Name must be 6 letters and numbers`
  String get Name_must_be_6_letters_and_numbers {
    return Intl.message(
      'Name must be 6 letters and numbers',
      name: 'Name_must_be_6_letters_and_numbers',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get Change_Password {
    return Intl.message(
      'Change Password',
      name: 'Change_Password',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 4 - 6 digits or characters`
  String get Password_must_be_4_6_digits_or_characters {
    return Intl.message(
      'Password must be 4 - 6 digits or characters',
      name: 'Password_must_be_4_6_digits_or_characters',
      desc: '',
      args: [],
    );
  }

  /// `Password can't be empty!`
  String get Password_cant_be_empty {
    return Intl.message(
      'Password can\'t be empty!',
      name: 'Password_cant_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `Password must be 6 letters and numbers!`
  String get Password_must_be_6_letters_and_numbers {
    return Intl.message(
      'Password must be 6 letters and numbers!',
      name: 'Password_must_be_6_letters_and_numbers',
      desc: '',
      args: [],
    );
  }

  /// `Password and confirm password must be the same!`
  String get Password_and_confirm_password_must_be_the_same {
    return Intl.message(
      'Password and confirm password must be the same!',
      name: 'Password_and_confirm_password_must_be_the_same',
      desc: '',
      args: [],
    );
  }

  /// `Device Name`
  String get Device_Name {
    return Intl.message(
      'Device Name',
      name: 'Device_Name',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get Available {
    return Intl.message(
      'Available',
      name: 'Available',
      desc: '',
      args: [],
    );
  }

  /// `Not Available`
  String get Not_Available {
    return Intl.message(
      'Not Available',
      name: 'Not_Available',
      desc: '',
      args: [],
    );
  }

  /// `Solar Cells`
  String get Solar_Cells {
    return Intl.message(
      'Solar Cells',
      name: 'Solar_Cells',
      desc: '',
      args: [],
    );
  }

  /// `Battery`
  String get Battery {
    return Intl.message(
      'Battery',
      name: 'Battery',
      desc: '',
      args: [],
    );
  }

  /// `Charge`
  String get Charge {
    return Intl.message(
      'Charge',
      name: 'Charge',
      desc: '',
      args: [],
    );
  }

  /// `Unique ID`
  String get Unique_ID {
    return Intl.message(
      'Unique ID',
      name: 'Unique_ID',
      desc: '',
      args: [],
    );
  }

  /// `Modal`
  String get Modal {
    return Intl.message(
      'Modal',
      name: 'Modal',
      desc: '',
      args: [],
    );
  }

  /// `Serial Number`
  String get Serial_Number {
    return Intl.message(
      'Serial Number',
      name: 'Serial_Number',
      desc: '',
      args: [],
    );
  }

  /// `Hw Version`
  String get Hw_Version {
    return Intl.message(
      'Hw Version',
      name: 'Hw_Version',
      desc: '',
      args: [],
    );
  }

  /// `Software Platform`
  String get Software_Platform {
    return Intl.message(
      'Software Platform',
      name: 'Software_Platform',
      desc: '',
      args: [],
    );
  }

  /// `Software Version`
  String get Software_Version {
    return Intl.message(
      'Software Version',
      name: 'Software_Version',
      desc: '',
      args: [],
    );
  }

  /// `Manufacturer`
  String get Manufacturer {
    return Intl.message(
      'Manufacturer',
      name: 'Manufacturer',
      desc: '',
      args: [],
    );
  }

  /// `Page`
  String get Page {
    return Intl.message(
      'Page',
      name: 'Page',
      desc: '',
      args: [],
    );
  }

  /// `Boot Time Length`
  String get Boot_Time_Length {
    return Intl.message(
      'Boot Time Length',
      name: 'Boot_Time_Length',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to exit?`
  String get Do_you_want_to_exit {
    return Intl.message(
      'Do you want to exit?',
      name: 'Do_you_want_to_exit',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for controller reboot. You need reconnect device to take effects.`
  String
      get Please_wait_for_controller_reboot_You_need_reconnect_device_to_take_effects {
    return Intl.message(
      'Please wait for controller reboot. You need reconnect device to take effects.',
      name:
          'Please_wait_for_controller_reboot_You_need_reconnect_device_to_take_effects',
      desc: '',
      args: [],
    );
  }

  /// `Target device does not support changing the password.`
  String get Target_device_does_not_support_changing_the_password {
    return Intl.message(
      'Target device does not support changing the password.',
      name: 'Target_device_does_not_support_changing_the_password',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported device`
  String get Unsupported_device {
    return Intl.message(
      'Unsupported device',
      name: 'Unsupported_device',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for controller reboot. You need reconnect device.`
  String get Please_wait_for_controller_reboot_You_need_reconnect_device {
    return Intl.message(
      'Please wait for controller reboot. You need reconnect device.',
      name: 'Please_wait_for_controller_reboot_You_need_reconnect_device',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for the controller reboot, waiting to reconnect...`
  String get Please_wait_for_the_controller_reboot_wainting_to_reconnect {
    return Intl.message(
      'Please wait for the controller reboot, waiting to reconnect...',
      name: 'Please_wait_for_the_controller_reboot_wainting_to_reconnect',
      desc: '',
      args: [],
    );
  }

  /// `Please wait...`
  String get Please_wait {
    return Intl.message(
      'Please wait...',
      name: 'Please_wait',
      desc: '',
      args: [],
    );
  }

  /// `Read success`
  String get Read_success {
    return Intl.message(
      'Read success',
      name: 'Read_success',
      desc: '',
      args: [],
    );
  }

  /// `Rebooting`
  String get Rebooting {
    return Intl.message(
      'Rebooting',
      name: 'Rebooting',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
