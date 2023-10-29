import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_car/models/mycar_item.dart';

class ListaSostituzioni extends StatefulWidget {
  const ListaSostituzioni({super.key});

  @override
  State<ListaSostituzioni> createState() => _ListaSostituzioniState();
}

class _ListaSostituzioniState extends State<ListaSostituzioni> {
  List<MycarItem> _mycarItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Getall all'apertura dell'App
  void _loadItems() async {
    try {
      final url = Uri.https(
          'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
          'mycar.json');
      final response = await http.get(url);
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<MycarItem> _loadedItems = [];
      for (final item in listData.entries) {
        final id = item.key;
        final dataCambio = item.value['dataCambio'] as String? ??
            "No Data"; // ' ?? "No Data" ' sta per 'se non è una stringa applica questa stringa di fallback". È indispensabile per dare all'App una stringa di riserva da inserire nel caso il valore fosse null
        final km = item.value['km'] as String? ?? "No Data";
        final nome = item.value['nome'] as String? ?? "No Data";

        _loadedItems.add(
          MycarItem(
            id: id,
            nome: nome,
            km: km,
            dataCambio: dataCambio,
          ),
        );
      }
      setState(() {
        _mycarItems = _loadedItems;
      });
    } catch (error) {
      print("Error loading data: $error");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text("Errore"),
                content: Text("Si è verificato il seguente errore: $error"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // chiude il dialog
                    },
                    child: const Text("OK"),
                  )
                ]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget carName = const Text('Ford Fiesta');
    Widget actualKm = const Text('Km Attuali 150.000');
    Widget content = const Center(child: Text('Nessun dato presente'));

    if (_mycarItems.isNotEmpty) {

// VARIANTE CON TABELLA //
      content = SingleChildScrollView(
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle, // Align content vertically in the middle
            columnWidths: const {
              // Definisco la larghezza di ogni colonna rispetto allo standard assegnato dividendo le colonne in parti uguali (nel caso di tre colonne 1 è uguale a un terzo, 2 a due terzi)
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(0.8),
              2: FlexColumnWidth(1),
            },
            children: _mycarItems.map((item) {
              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Text(
                          item.nome,
                          style: const TextStyle(fontSize: 16, fontWeight:FontWeight.w600),
                        ),
                      ),
                    ),
                  TableCell(
                    child: Text(
                      item.km,
                      style: const TextStyle(fontSize: 16, fontWeight:FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                      child: Text(
                          item.dataCambio,
                          style: const TextStyle(fontSize: 15, fontWeight:FontWeight.w500),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
                  
// VARIANTE CON TABELLA - FINE //

// VARIANTE CON LIST TILE //
              // content = Expanded(
              // child: ListView.builder(
              //     itemCount: _mycarItems.length,
              //     itemBuilder: (context, index) =>
              // ListTile(
              //   key: ValueKey(_mycarItems[index].id),
              //   title: Text(
              //     _mycarItems[index].km,
              //     style: const TextStyle(fontSize: 16, fontWeight:FontWeight.w600),
              //     textAlign: TextAlign.right,
              //   ),
              //   leading: ConstrainedBox(
              //     constraints: const BoxConstraints(maxWidth: 150),
              //     child: Text(
              //       _mycarItems[index].nome,
              //       style: const TextStyle(fontSize: 15, fontWeight:FontWeight.w600)
              //     ),
              //   ),
              //   trailing: Text(
              //     _mycarItems[index].dataCambio,
              //     style: const TextStyle(fontSize: 14, fontWeight:FontWeight.w500),
              //     textAlign: TextAlign.end,
              //   )
              // )
              // ));
// VARIANTE CON LIST TILE - FINE //
      );
    }

    return Scaffold(
      body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: carName,
          )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: actualKm
          ),
        ),
        content
      ],
    ));
  }
}