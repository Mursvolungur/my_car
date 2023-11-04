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
  // Questo oggetto viene utilizzato per identificare e gestire il form.
  // Per catturare i dati inseriti dall'utente e prepararli per l'invio, devi chiamare il metodo save() dell'oggetto FormState associato al tuo form.
  final _formKey = GlobalKey<FormState>();
  var _newName = '';
  var _newKm = '';
  var _newChangeDate = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _saveItem() async {
    _formKey.currentState!.save();
    final url = Uri.https(
        'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
        'mycar.json');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nome': _newName,
          'km': _newKm,
          'dataCambio': _newChangeDate,
        }));
    _loadItems(); // Aggiorna la pagina richiamando _loadItems
    _formKey.currentState!.reset(); // Resetta i campi di modifica una volta inviata la post
    // TODO: TOGLIERE IL FOCUS UNA VOLTA INVIATA LA POST O QUANDO SI CLICCA FUORI DAI FORM FIELD
    print(response.headers);
    print(response.body);
    print(response.statusCode);
  }

  void _editItem(MycarItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modifica dati"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: item.nome, // All'apertura del dialog vedi il valore attuale
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {    // PER QUALCHE STRANA RAGIONE CON onSaved NON FUNZIONA
                  print(value);
                  item.nome = value!;
                }
              ),
              TextFormField(
                initialValue: item.km,
                decoration: const InputDecoration(labelText: 'Km'),
                onChanged: (value) {
                  print(value);
                  item.km = value!;
                }
              ),
              TextFormField(
                initialValue: item.dataCambio,
                decoration: const InputDecoration(labelText: 'Data Cambio'),
                onChanged: (value) {
                  print(value);
                  item.dataCambio = value!;
                }
              ),
            ]
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Chiude il dialog
              },
              child: const Text('Annulla')
            ),
            TextButton(
              onPressed: () {
                _saveChanges(item);           // Richiama la funzione che fa la PATCH e
                Navigator.of(context).pop();  // poi chiude il dialog
              },
              child: const Text('Salva')
            )
          ]
        );
      }
    );
  }

  // Patch per modifica dati esistenti
  void _saveChanges(MycarItem item) async {
      final url = Uri.https(
        'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
        'mycar/${item.id}.json'
      );
      final response = await http.patch(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nome': item.nome,
          'km': item.km,
          'dataCambio': item.dataCambio
        })
      );
      print(response.headers);
      print(response.body);
      print(response.statusCode);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati aggiornati con successo')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante l\'aggiornamento dei dati')),
      );
    }
    _loadItems(); // Aggiorna la pagina richiamando _loadItems
  }

  // Getall all'apertura dell'app
  void _loadItems() async {
    try {
      final url = Uri.https(
        'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
        'mycar.json'
      );
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
      debugPrint("Error loading data: $error");
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
    Widget carName = const Text(
      'Ford Fiesta',
      style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color.fromARGB(255, 35, 92, 184)),
    );
    Widget actualKm = const Text('Km Attuali',
        style: TextStyle(
          fontSize: 16,
        ));
    Widget actualKmValue = const Text(
      '82.000',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
    Widget content = const Center(child: Text('Nessun dato presente'));

    if (_mycarItems.isNotEmpty) {
      content = ListView(
      shrinkWrap: true, // Allow the ListView to take only the necessary space
      children: [
      // VARIANTE CON TABELLA //
      Table(
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
                child: GestureDetector(
                  onTap: () {
                    _editItem(item);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Text(
                      item.nome,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              TableCell(
                child: GestureDetector(
                  onTap: () {
                    _editItem(item);
                  },
                  child: Text(
                    item.km,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              TableCell(
                child: GestureDetector(
                  onTap: () {
                    _editItem(item);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                    child: Text(
                      item.dataCambio,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      )
      ]

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
        body: Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 8, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: carName,
          )),
      Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Align(alignment: Alignment.centerRight, child: actualKm),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(alignment: Alignment.centerRight, child: actualKmValue),
        ),
      ]),
      Column(
        children: [
          SizedBox(
            height: 250,
            child: content),
          // Input fields for adding new data
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 8, 16),
              child: Form(
                  key: _formKey,
                  child: Row(children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        // maxLength: 40,
                        decoration:
                            const InputDecoration(labelText: 'Aggiungi'),
                        // Store the value entered by the user for nome.
                        // You can use a TextEditingController for this.
                        onSaved: (value) {
                          _newName = value!;
                          debugPrint(_newName);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                          decoration: const InputDecoration(labelText: ''),
                          onSaved: (value) {
                            _newKm = value!;
                          }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                          decoration: const InputDecoration(labelText: ''),
                          onSaved: (value) {
                            _newChangeDate = value!;
                          }),
                    ),
                    const SizedBox(width: 8),
                  ]))),
          ElevatedButton(
            onPressed: _saveItem,
            // Handle the submission of the new data.
            // Add the new entry to your _mycarItems list or database.
            child: const Text(
              'Salva elemento aggiunto',
              style: TextStyle(
                color: Colors.white),
            ),
          ),
        ],
      )
    ]));
  }
}
