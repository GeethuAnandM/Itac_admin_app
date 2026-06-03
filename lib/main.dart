import 'package:admin_app/screens/adminlogin.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// 'package:shared_preferencimportes/shared_preferences.dart';
import 'languges/language_constants.dart';
import 'screens/color.dart';
import 'package:admin_app/screens/dashboardScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/themenotifier.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var themecolruserselected = "Blue And Indigo";
var languageuserselected = "English";
final storagemain = FlutterSecureStorage();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  var themeColor = pref.getString("ThemeMode");
  print("theme color ${themeColor}");
  if (themeColor == "Indigo And Pink") {
    themecolruserselected = "Indigo And Pink";
    activeTheme = indigoAndPinkTheme;
  } else if (themeColor == "Deep Purple And Amber") {
    themecolruserselected = "Deep Purple And Amber";
    activeTheme = deepPurpleAndAmberTheme;
  } else if (themeColor == "Pink And Blue Grey") {
    themecolruserselected = "Pink And Blue Grey";
    activeTheme = pinkAndBlueGreyTheme;
  } else {
    themecolruserselected = "Blue And Indigo";
    activeTheme = blueAndIndigoTheme;
  }
  var lang = pref.getString(LANGUAGE_CODE) ??
      await storagemain.read(key: LANGUAGE_CODE) ??
      ENGLISH;
  print(lang);
  switch (lang) {
    case ENGLISH:
      languageuserselected = "English";
      break;
    case FRENCH:
      languageuserselected = "French";
      break;
    case HINDI:
      languageuserselected = "Hindi";
      break;
    default:
      languageuserselected = "English";
  }
  ;

  runApp(DevicePreview(
      enabled: false,
      builder: (BuildContext context) {
        return MultiProvider(providers: [
          ChangeNotifierProvider(
              create: (context) => ThemeNotifier(activeTheme!)),
        ], child: const AdminApp());
      }));
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
  static void setLocale(BuildContext context, Locale newLocale) {
    _AdminAppState? state = context.findAncestorStateOfType<_AdminAppState>();
    state?.setLocale(newLocale);
  }
}

Locale? _locale;

class _AdminAppState extends State<AdminApp> {
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  Future<bool> checkloggedstats() async {
    final prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool("status") ?? false;
    print("status:${prefs.getBool("status")}");
    if (status == false) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.0);
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
        );
      },

      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: FutureBuilder(
          future: checkloggedstats(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return Dashboard();
                } else {
                  return AdminLogin();
                  // return Dashboard();
                }
              }
            }
            return AdminLogin();
          }),
      // Dashboard(),
    );
  }
}
