import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutternotsepeti/kategori_islemleri.dart';
import 'package:flutternotsepeti/models/kategori.dart';
import 'package:flutternotsepeti/models/notlar.dart';
import 'package:flutternotsepeti/not_detay.dart';
import 'package:flutternotsepeti/utils/database_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Sepeti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Raleway',
          primarySwatch: Colors.purple,
          accentColor: Colors.orange),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Kategori> tumKategoriler = List<Kategori>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Not Sepeti",
          style: TextStyle(fontFamily: "Raleway", fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.import_contacts, color: Colors.orange,),
                    title: Text("Kategoriler", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w700),),
                    onTap: () {
                      Navigator.pop(context);
                      _kategorilerSayfasinaGit(context);
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              kategoriEkleDialog(context);
            },
            heroTag: "KategoriEkle",
            tooltip: "Kategori Ekle",
            child: Icon(
              Icons.import_contacts,
              color: Colors.white,
            ),
            mini: true,
          ),
          FloatingActionButton(
            tooltip: "Not Ekle",
            heroTag: "NotEkle",
            onPressed: () => tumKategoriler.length == 0
                ? _detaySayfasinaGit(context)
                : _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text("Kategori Boş!!! Önce Kategori Ekleyiniz."),
                duration: Duration(seconds: 2),
              ),
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (yeniDeger) {
                      yeniKategoriAdi = yeniDeger;
                    },
                    decoration: InputDecoration(
                      labelText: "Kategori Adı",
                      border: OutlineInputBorder(),
                    ),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi.length < 3) {
                        return "En az 3 karakter giriniz";
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.orangeAccent,
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor),
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .kategoriEkle(Kategori(yeniKategoriAdi))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Kategori Eklendi"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    color: Colors.redAccent,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  _detaySayfasinaGit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Yeni Not",
                )));
  }

  void _kategorilerSayfasinaGit(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Kategoriler()));
  }
}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleBaslik = Theme.of(context).textTheme.body1.copyWith(
        fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Raleway');

    return FutureBuilder(
      future: databaseHelper.notListesiniGetir(),
      builder: (context, AsyncSnapshot<List<Not>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          tumNotlar = snapShot.data;
          sleep(Duration(milliseconds: 500));
          return ListView.builder(
              itemCount: tumNotlar.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                  title: Text(
                    tumNotlar[index].notBaslik,
                    style: textStyleBaslik,
                  ),
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Kategori",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tumNotlar[index].kategoriBaslik,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Oluşturulma Tarihi",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  databaseHelper.dateFormat(DateTime.parse(
                                      tumNotlar[index].notTarih)),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "İçerik",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                child: Text(
                                  tumNotlar[index].notIcerik,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              OutlineButton(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  onPressed: () =>
                                      _notSil(tumNotlar[index].notID),
                                  child: Text(
                                    "SİL",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  )),
                              OutlineButton(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor),
                                  onPressed: () {
                                    _detaySayfasinaGit(
                                        context, tumNotlar[index]);
                                  },
                                  child: Text(
                                    "GÜNCELLE",
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        } else {
          return Center(child: Text("Yükleniyor..."));
        }
      },
    );
  }

  _detaySayfasinaGit(BuildContext context, Not not) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotDetay(
                  baslik: "Notu Düzenle",
                  duzenlenecekNot: not,
                )));
  }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
            radius: 26,
            child: Text(
              "AZ",
              style: TextStyle(
                  color: Colors.deepOrange.shade200,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blueGrey.shade200);
        break;
      case 1:
        return CircleAvatar(
            radius: 26,
            child: Text(
              "ORTA",
              style: TextStyle(
                  color: Colors.deepOrange.shade400,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blueGrey.shade200);
      case 2:
        return CircleAvatar(
            radius: 26,
            child: Text(
              "ACIL",
              style: TextStyle(
                  color: Colors.deepOrange.shade700,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blueGrey.shade200);
        break;
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID) {
      if (silinenID != 0) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Not Silindi")));

        setState(() {});
      }
    });
  }
}
