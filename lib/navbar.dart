
import 'package:flutter/material.dart';
import 'announcement_page.dart';
import 'search_page.dart';
import 'package:google_fonts/google_fonts.dart';

/// This class models the navigation bar that allows the user to navigate between the [SearchPage] and the [AnnouncementsPage].
class Navbar extends StatefulWidget {
  const Navbar({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow from the app bar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.purple.shade900],
              // Set the gradient colors
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/ULogo.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(width: 10),
            Text(
              'UNav',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SearchPage(),
                AnnouncementPage(),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.blue.shade900],
                // Set the gradient colors
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.search),
                  text: 'Search',
                ),
                Tab(
                  icon: Icon(Icons.announcement),
                  text: 'Announcements',
                ),
              ],
              indicatorColor: Colors.white,
              // Set the indicator color
              labelColor: Colors.white,
              // Set the label color
              unselectedLabelColor: Colors.white
                  .withOpacity(0.6), // Set the unselected label color
            ),
          ),
        ],
      ),
    );
  }
}
