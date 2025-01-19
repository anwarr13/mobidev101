import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Import the signup screen to navigate after logout

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: DashboardScreen());
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // List of widgets for each tab
  static final List<Widget> _pages = <Widget>[
    Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search locations...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            '', // Locations Page
            style: TextStyle(fontSize: 23),
          ),
        ),
      ],
    ),
    // List Page: Scrollable with six items
    SingleChildScrollView(
      child: Column(
        children: List.generate(6, (index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[300],
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey, // Placeholder for the image
                ),
                title: const Text('Lorem ipsum dolor',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                ),
              ),
            ),
          );
        }),
      ),
    ),
    // Updated Settings Page
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 20),
          _SettingsButton(label: 'Edit Profile'),
          _SettingsButton(label: 'Change Password'),
          _SettingsButton(label: 'About'),
          const SizedBox(height: 15),
          _SettingsButton(label: 'Logout', isLogout: true),
        ],
      ),
    ),
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
        title: const Text('ShatSpot'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ), // BottomNavigationBar
    ); // Scaffold
  }
}

// Reusable button widget for settings
class _SettingsButton extends StatelessWidget {
  final String label;
  final bool isLogout;

  const _SettingsButton({
    required this.label,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          if (isLogout) {
            _showLogoutConfirmation(context);
          } else {
            print('$label tapped');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLogout ? Colors.red : Colors.grey[300],
          foregroundColor: isLogout ? Colors.white : Colors.black,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SignupScreen()), // Navigate to signup screen
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
