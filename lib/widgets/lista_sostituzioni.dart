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
  final GlobalKey<ScaffoldState> _modalScaffoldKey = GlobalKey<ScaffoldState>();
  var _newName = '';
  var _newKm = '';
  var _newChangeDate = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Scaffold(
        key: _modalScaffoldKey, // la key è una sorta di ID del widget, qui non è indispensabile
        extendBody: false,  // Se impostato su false, il corpo sarà posizionato sopra la barra di navigazione inferiore. Questo è utile per evitare che i widget si sovrappongano alla barra di navigazione inferiore
        resizeToAvoidBottomInset: true, // Questa proprietà controlla se la parte inferiore del corpo deve essere ridimensionata automaticamente quando la tastiera appare. Se impostato su true, il corpo verrà ridimensionato in modo da evitare che la tastiera copra il contenuto inferiore
        backgroundColor: Colors.transparent,
        body: AlertDialog(
          title: const Text("Aggiungi dati"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  _newName = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Km'),
                onChanged: (value) {
                  _newKm = value;
                },
                keyboardType:TextInputType.datetime,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Data Cambio'),
                onChanged: (value) {
                  _newChangeDate = value;
                },
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newName = '';
                _newKm = '';
                _newChangeDate = '';
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                if (_newName == '' || (_newKm == '' && _newChangeDate == '')){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inserire il nome del pezzo e i km o la data al momento del cambio')),
                  );
                } else {
                _saveNewItem();
                Navigator.of(context).pop();
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNewItem() async {
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
    print(response.headers);
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      if (_modalScaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(_modalScaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Dati aggiunti con successo')),
        );
      }
    } else {
      ScaffoldMessenger.of(_modalScaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Errore durante l\'aggiornamento dei dati')
        ),
      );
    }
    _loadItems(); // Aggiorna la pagina richiamando _loadItems
    _newName = '';
    _newKm = '';
    _newChangeDate = '';
  }

  void _editActualKm(MycarItem _mycarItems) {
    int newKmValue = _mycarItems.actualKm;
    showDialog(
      context: context,
      builder: (BuildContext context) => Scaffold(
        key: _modalScaffoldKey,
        extendBody: false,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: AlertDialog(
          title: const Text("Aggiorna i Km totali"),
          content: Column(mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
              initialValue: _mycarItems.actualKm.toString(),
              onChanged: (value) {
                int? parsedValue = int.tryParse(value);
                if (parsedValue != null) {
                  setState(() {
                    newKmValue = parsedValue;
                  });
                }
              },
              keyboardType: TextInputType.number,
            )
          ]),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialog
              },
              child: const Text('Annulla')),
            TextButton(
              onPressed: () {
                _saveNewActualKm(_mycarItems, newKmValue);  // Richiama la funzione che fa la PATCH e
                print('newKmValue = ');
                print(newKmValue);
                Navigator.of(context).pop();    // poi chiude il dialog
              },
              child: const Text('Salva')
            )
          ]
        )
      )
    );
  }

  void _editItem(MycarItem item) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Scaffold(
          key: _modalScaffoldKey, // la key è una sorta di ID del widget
          extendBody: false,  // Se impostato su false, il corpo sarà posizionato sopra la barra di navigazione inferiore. Questo è utile per evitare che i widget si sovrappongano alla barra di navigazione inferiore
          resizeToAvoidBottomInset: true, // Questa proprietà controlla se la parte inferiore del corpo deve essere ridimensionata automaticamente quando la tastiera appare. Se impostato su true, il corpo verrà ridimensionato in modo da evitare che la tastiera copra il contenuto inferiore
          backgroundColor: Colors.transparent,
          body: AlertDialog(
              title: const Text("Modifica dati"),
              content: Column(mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: item.nome,  // All'apertura del dialog vedi il valore attuale
                  decoration: const InputDecoration(labelText: 'Nome'),
                  onChanged: (value) {      // con onSaved non funziona
                    print(value);
                    item.nome = value;
                  }
                ),
                TextFormField(
                  initialValue: item.km,
                  decoration: const InputDecoration(labelText: 'Km'),
                  onChanged: (value) {
                    print(value);
                    item.km = value;
                  },
                  keyboardType: TextInputType.datetime,
                ),
                TextFormField(
                  initialValue: item.dataCambio,
                  decoration: const InputDecoration(labelText: 'Data Cambio'),
                  onChanged: (value) {
                    print(value);
                    item.dataCambio = value;
                  },
                  keyboardType: TextInputType.datetime,
                ),
              ]),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();  // Chiude il dialog
                    _loadItems();                 // Ricarica i valori dal DB, altrimenti visualizza la modifica fatta in locale (item.nome = value) anche se non inviata con "Salva"
                  },
                  child: const Text('Annulla')
                ),
                TextButton(
                  onPressed: () {
                    _saveChanges(item); // Richiama la funzione che fa la PATCH e
                    Navigator.of(context).pop(); // poi chiude il dialog
                  },
                  child: const Text('Salva')
                )
              ])
    ));
  }

  // Patch per modifica dati esistenti
  void _saveChanges(MycarItem item) async {
    final url = Uri.https(
        'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
        'mycar/${item.id}.json');
    final response = await http.patch(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
            {'nome': item.nome, 'km': item.km, 'dataCambio': item.dataCambio}));
    print(response.headers);
    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      if (_modalScaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(_modalScaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Dati aggiornati con successo')),
        );
      }
    } else {
      ScaffoldMessenger.of(_modalScaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
            content: Text('Errore durante l\'aggiornamento dei dati')),
      );
    }
    _loadItems(); // Aggiorna la pagina richiamando _loadItems
  }

  // Patch per modifica dati esistenti
  void _saveNewActualKm(MycarItem _mycarItems, newKmValue) async {
    final url = Uri.https(
      'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
      'mycar.json');
    final response = await http.patch(url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {'kmAttuali': newKmValue}
      )
    );
    print(response.headers);
    print(response.body);
    print(response.statusCode);
    
    if (response.statusCode == 200) {
      if (_modalScaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(_modalScaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Dati aggiornati con successo')),
        );
      }
    } else {
      ScaffoldMessenger.of(_modalScaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Errore durante l\'aggiornamento dei dati')
        ),
      );
    }
    _loadItems(); // Aggiorna la pagina richiamando _loadItems
  }

  // Getall all'apertura dell'app
  void _loadItems() async {
    try {
      final url = Uri.https(
          'corso-flutter-63be3-default-rtdb.europe-west1.firebasedatabase.app',
          'mycar.json');
      final response = await http.get(url);
      final Map<String, dynamic> listData = json.decode(response.body);
      final actualKm = listData['kmAttuali'] as int? ?? 0;
      final List<MycarItem> _loadedItems = [];
      for (final item in listData.entries) {
        if (item.key != 'kmAttuali') {  // Quando cicla non deve aggiungere il valore kmAttuali all'array, è un valore unico, non è da ciclare
          final id = item.key;
          final dataCambio = item.value['dataCambio'] as String? ??
              "No Data"; // ' ?? "No Data" ' sta per 'se non è una stringa applica questa stringa di fallback". È indispensabile per dare all'App una stringa di riserva da inserire nel caso il valore fosse null (ad esempio in caso di cancellazione da DB)
          final km = item.value['km'] as String? ?? "No Data";
          final nome = item.value['nome'] as String? ?? "No Data";

          _loadedItems.add(
            MycarItem(
              actualKm: actualKm,
              id: id,
              nome: nome,
              km: km,
              dataCambio: dataCambio,
            ),
          );
        }
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
              ]
            );
          }
        );
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
    Widget headerActualKm = const Text('Km Attuali',
        style: TextStyle(
          fontSize: 16,
        ));
    Widget actualKmValue =  const Text('Nessun dato presente');
      if (_mycarItems.isNotEmpty) {
        actualKmValue = GestureDetector(
          onTap: () {
            _editActualKm(_mycarItems.first);
          },
          child: Text(
            _mycarItems.first.actualKm.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }

    Widget content = const Center(child: Text('Nessun dato presente'));

    if (_mycarItems.isNotEmpty) {
      content = ListView(
        shrinkWrap:
            true, // Allow the ListView to take only the necessary space
        children: [
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment
                .middle, // Align content vertically in the middle
            columnWidths: const {
              // Definisco la larghezza di ogni colonna rispetto allo standard assegnato dividendo le colonne in parti uguali (nel caso di tre colonne 1 è uguale a un terzo, 2 a due terzi)
              0: FlexColumnWidth(1.3),
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
      );
    }
    
    final screenSize = MediaQuery.of(context).size; // Prende dimensioni schermo
    double normalHeight = 400;                      // Imposta altezza standard per il bottone "Aggiungi nuovo elemento"
    if (screenSize.height <= 700) {                 // Ma se lo schermo è corto (tipo Iphone 7) allora riduce l'altezza della colonna del bottone
      normalHeight = 300;
    }
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 8, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: carName,
              )),
          Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: headerActualKm
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: actualKmValue
              ),
            ),
          ]),
          Column(
            children: [
              SizedBox(
                height: normalHeight,
                child: content
              ),
              ElevatedButton(
                onPressed: _addItem,
                child: const Text(
                  'Aggiungi nuovo elemento',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ]
      )
    );
  }
}