import 'package:flutter/material.dart';
import 'package:whatzapp/model/country_model.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key, required this.setCountryData});
  final Function setCountryData;

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  List<CountryModel> countries = [
    CountryModel(name: "Dominican Republic", code: "+1", flag: "🇩🇴"),
    CountryModel(name: "Afghanistan", code: "+93", flag: "🇦🇫"),
    CountryModel(name: "Argentina", code: "+54", flag: "🇦🇷"),
    CountryModel(name: "Brazil", code: "+55", flag: "🇧🇷"),
    CountryModel(name: "Canada", code: "+1", flag: "🇨🇦"),
    CountryModel(name: "Chile", code: "+56", flag: "🇨🇱"),
    CountryModel(name: "Colombia", code: "+57", flag: "🇨🇴"),
    CountryModel(name: "Cuba", code: "+53", flag: "🇨🇺"),
    CountryModel(name: "Ecuador", code: "+593", flag: "🇪🇨"),
    CountryModel(name: "France", code: "+33", flag: "🇫🇷"),
    CountryModel(name: "Germany", code: "+49", flag: "🇩🇪"),
    CountryModel(name: "India", code: "+91", flag: "🇮🇳"),
    CountryModel(name: "Italy", code: "+39", flag: "🇮🇹"),
    CountryModel(name: "Jamaica", code: "+1", flag: "🇯🇲"),
    CountryModel(name: "Japan", code: "+81", flag: "🇯🇵"),
    CountryModel(name: "Mexico", code: "+52", flag: "🇲🇽"),
    CountryModel(name: "Pakistan", code: "+92", flag: "🇵🇰"),
    CountryModel(name: "Panama", code: "+507", flag: "🇵🇦"),
    CountryModel(name: "Peru", code: "+51", flag: "🇵🇪"),
    CountryModel(name: "Portugal", code: "+351", flag: "🇵🇹"),
    CountryModel(name: "South Africa", code: "+27", flag: "🇿🇦"),
    CountryModel(name: "Spain", code: "+34", flag: "🇪🇸"),
    CountryModel(name: "United Kingdom", code: "+44", flag: "🇬🇧"),
    CountryModel(name: "United States", code: "+1", flag: "🇺🇸"),
    CountryModel(name: "Venezuela", code: "+58", flag: "🇻🇪"),
  ];

  List<CountryModel> filtered = [];

  TextEditingController searchCtrl = TextEditingController();

  bool showSearch = false;

  @override
  void initState() {
    super.initState();
    filtered = countries;
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        filtered = countries;
      } else {
        filtered = countries
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.teal),
        ),
        title: showSearch
            ? TextField(
                controller: searchCtrl,
                autofocus: true,
                onChanged: filterCountries,
                decoration: InputDecoration(
                  hintText: "Search country...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black, fontSize: 16),
              )
            : Text(
                "Select your country",
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w700,
                  wordSpacing: 1,
                ),
              ),
        centerTitle: !showSearch,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) {
                  searchCtrl.clear();
                  filtered = countries;
                }
              });
            },
            icon: Icon(
              showSearch ? Icons.close : Icons.search,
              color: Colors.teal,
            ),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 10),
                  Text(
                    "No countries found",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (BuildContext context, int index) =>
                  card(filtered[index]),
            ),
    );
  }

  Widget card(CountryModel country) {
    return InkWell(
      onTap: () {
        widget.setCountryData(country);
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        elevation: 0.5,
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            children: [
              Text(country.flag, style: TextStyle(fontSize: 22)),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  country.name,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                country.code,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
