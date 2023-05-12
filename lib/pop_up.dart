import 'package:flutter/material.dart';
import 'package:flutter_workspace/navbar.dart';
import 'package:flutter_workspace/search_page.dart';
import 'package:google_fonts/google_fonts.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key});

  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();


    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Navbar(title:"UMass Navigation")),
      );
    });
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade900, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            FadeTransition(
                opacity: _animation,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Image.asset(
                'assets/ULogo.png', // Replace with your image path
                width: 600,
                height: 600,
                ),

              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 15, right:15, left:15),
                child: Text(
                  'Welcome to UNav, an app designed for navigating UMass Medical patients to their appointments.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(fontSize: 16, color: Colors.white,),
                  ),
                ),
              ),

            ],
          ),
        ),
    ],
      ),
    ),
      ),
    );
  }
}

