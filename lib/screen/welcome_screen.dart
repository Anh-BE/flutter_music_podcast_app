
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../colors/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'main_screen.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();

}
class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
            AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.spotify,
                        color: Color.fromARGB(255, 116, 2, 142),
                      size: 60,
                      ),
                    ),
                  const SizedBox(width: 16),
                    const Text(
                      "Music APP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                
             
                const SizedBox(height : 20),
                const Text(
                  "Your Music,\nEverywhere",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Stream unlimited songs, create playlists, and discover new music.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    SizedBox(
                      width: 145,
                      child: Column(
                        children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PhosphorIcon(
                            PhosphorIconsFill.musicNote,
                            color: AppColors.button,
                            size: 45,
                          ),
                        ),
                      const SizedBox(height: 8),
                        const Text(
                          "Unlimited Music", 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          "Stream milions of songs",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Colors.white54,
                            fontSize : 13,
                            
                            
                          ),
                        ),
                      ],
                    ),
                    ),
                  const SizedBox(width: 20),
                    SizedBox(
                      width: 145,
                      child: Column(
                        children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PhosphorIcon(
                            PhosphorIconsFill.headphones,
                            size: 45,
                            color: AppColors.button,
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Text(
                        "High Quality",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          "Crystal clear audio",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Colors.white54,
                            fontSize : 13,
                            
                            
                          ),
                        ),
                      ],
                    
                      ),
                    ),
                  ],
                ),
                const SizedBox(height : 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 145,
                      child: Column(
                        children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PhosphorIcon(
                            PhosphorIconsFill.heartStraight,
                            color: AppColors.button,
                            size: 45,
                          ),
                        ),
                      const SizedBox(height: 8),
                        const Text(
                        "Your Favorites",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          "Create custom playlists",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Colors.white54,
                            fontSize : 13,
                            
                            
                          ),
                        ),
                      ],
                    ),
                    ),
                  const SizedBox(width: 20),
                    SizedBox(
                    width: 145,
                      child: Column(
                        children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PhosphorIcon(
                            PhosphorIconsFill.shareNetwork,
                            size: 45,
                            color: AppColors.button,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Text(
                        "Share & Discover",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 15,
                          ),
                        ),
                      

                        const Text(
                          "Connect with friends",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Colors.white54,
                            fontSize : 13,
                            
                            
                          ),
                        ),
                        
                      ],
                    
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
               
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

}