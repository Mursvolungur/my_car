import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_car/widgets/lista_sostituzioni.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // String version = packageInfo.version;
  // runApp(MyApp(version: version)); }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String appTitle = 'My Car';

  final Future<String> _versionFuture = getVersionInfo();

  // Metodo per ottenere le informazioni sulla versione
  static Future<String> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
          return MaterialApp(
            title: 'My Car',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.lightBlue.shade900,
                surface: const Color.fromARGB(255, 50, 107, 200)
              ),
            ),
            home: Scaffold(
              appBar: AppBar(
                title: Text(appTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child:
                        ListaSostituzioni(), // Il corpo principale della pagina
                  ),
                  FutureBuilder<String>(
                    future: _versionFuture,
                    builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text("Errore nel recupero della versione dell'app");
                } else {
                  final version = snapshot.data;
                  // Mostra il container con la versione una volta ottenuta
                  return Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 24, 48),
                    child: Text(
                      '$version \n Beta version',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  );
                }
              }
            )
          ]
        )
      )
    );
  }
}