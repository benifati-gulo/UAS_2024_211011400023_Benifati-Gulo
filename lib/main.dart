import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Prices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CryptoListScreen(),
    );
  }
}

class Crypto {
  final String name;
  final String symbol;
  final double priceUsd;

  Crypto({
    required this.name,
    required this.symbol,
    required this.priceUsd,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      name: json['name'],
      symbol: json['symbol'],
      priceUsd: double.parse(json['price_usd']),
    );
  }
}

class ApiService {
  Future<List<Crypto>> fetchCryptos() async {
    final response =
        await http.get(Uri.parse('https://api.coinlore.net/api/tickers/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> cryptosJson = data['data'];
      return cryptosJson.map((json) => Crypto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cryptos');
    }
  }
}

class CryptoListScreen extends StatefulWidget {
  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  late Future<List<Crypto>> futureCryptos;

  @override
  void initState() {
    super.initState();
    futureCryptos = ApiService().fetchCryptos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Prices'),
      ),
      body: FutureBuilder<List<Crypto>>(
        future: futureCryptos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Crypto crypto = snapshot.data![index];
                return ListTile(
                  title: Text(crypto.name),
                  subtitle: Text(crypto.symbol),
                  trailing: Text('\$${crypto.priceUsd.toStringAsFixed(2)}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
