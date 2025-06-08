import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(PowerCareApp());
}

class PowerCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerCare',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
      ),
      home: PowerCareHome(),
    );
  }
}

class PowerCareHome extends StatefulWidget {
  @override
  _PowerCareHomeState createState() => _PowerCareHomeState();
}

class _PowerCareHomeState extends State<PowerCareHome> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    Text('Train', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold)),
    Text('Camp', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold)),
    Text('Discover', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold)),
    Text('Profile', style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PowerCare', style: GoogleFonts.bebasNeue(textStyle: TextStyle(fontSize: 24))),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.dumbbell),
            label: 'Train',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.personBooth),
            label: 'Camp',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
