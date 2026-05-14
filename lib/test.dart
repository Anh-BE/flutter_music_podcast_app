import 'package:flutter/material.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.keyboard_arrow_down),
        title: const Text('Now Playing', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Ciray Remix-Cover', style: TextStyle(color: Colors.grey)),
            const Text('- - - -', style: TextStyle(color: Colors.grey)),
            
            const Spacer(),

            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('URL_ANH_CUA_BAN'), 
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.share_outlined),
                Column(
                  children: [
                    const Text('Đế Vương', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Đình Dũng', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const Icon(Icons.favorite_border),
              ],
            ),

            const SizedBox(height: 30),

            Slider(
              value: 0.2, 
              onChanged: (val) {},
              activeColor: Colors.deepPurple,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('0:00'), Text('3:19')],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.shuffle, color: Colors.grey),
                const Icon(Icons.skip_previous, size: 40),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
                const Icon(Icons.skip_next, size: 40),
                const Icon(Icons.repeat, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}