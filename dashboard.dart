import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'signup_screen.dart';
import 'editprofilescreen.dart';
import 'aboutscreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Default to the Locations tab
  String username = 'Default Username'; // Default username
  GoogleMapController? mapController;

  // Ipil, Zamboanga Sibugay, Philippines
  static const LatLng _ipilLocation = LatLng(7.7844, 122.5901);

  // Initial camera position for the map
  static const CameraPosition _initialPosition = CameraPosition(
    target: _ipilLocation,
    zoom: 14,
  );

  // Getter for pages to dynamically reflect username changes
  List<Widget> get _pages => <Widget>[
        // Locations Tab
        Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                const Marker(
                  markerId: MarkerId('ipil_center'),
                  position: _ipilLocation,
                  infoWindow: InfoWindow(
                    title: 'Ipil',
                    snippet: 'Zamboanga Sibugay, Philippines',
                  ),
                ),
              },
            ),
            // Search bar inside the map
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search locations...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // List Tab
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
                    title: const Text(
                      'Lorem ipsum dolor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Settings Tab
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 5),
              Text(
                username,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _SettingsButton(
                label: 'Edit Profile',
                onTap: () async {
                  final updatedName = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(initialName: username),
                    ),
                  );
                  if (updatedName != null && updatedName is String) {
                    setState(() {
                      username = updatedName;
                    });
                  }
                },
              ),
              _SettingsButton(label: 'Change Password'),
              _SettingsButton(
                label: 'About',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),
              _SettingsButton(
                label: 'Logout',
                isLogout: true,
                onTap: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
        ),
      ];

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
                _logout();
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Reflect the current tab
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
      ),
    );
  }
}

// Reusable button widget for settings
class _SettingsButton extends StatelessWidget {
  final String label;
  final bool isLogout;
  final VoidCallback? onTap;

  const _SettingsButton({
    required this.label,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
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
}
