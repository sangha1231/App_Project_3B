// lib/pages/settings_page.dart

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navHeight  = 60.0;
    const maxWidth   = 400.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      //─────────────────────────────────────────
      // BODY: background + scrollable content
      body: Stack(
        children: [
          // 1) Full‑screen background
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          // 2) SafeArea → centered, max‑width, scrollable
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      // back
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                          child: Image.asset(
                            'assets/images/arrow_back.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),

                      // title
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: const Text(
                          'SETTING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      // search
                      GestureDetector(onTap: () {}, child: Image.asset('assets/images/search.png')),
                      const SizedBox(height: 30),
                      // account
                      GestureDetector(onTap: () {}, child: Image.asset('assets/images/account.png')),
                      const SizedBox(height: 200), // extra space if needed
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      //─────────────────────────────────────────
      // BOTTOM NAVIGATION BAR: fills width, background + centered buttons
      bottomNavigationBar: SizedBox(
        height: navHeight + bottomInset,
        child: Container(
          width: double.infinity,
          // bar background
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bottom.png'),
              fit: BoxFit.cover,
            ),
          ),
          // slight bottom padding then center the two icons
          padding: EdgeInsets.only(bottom: bottomInset + 4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MainPage
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: Image.asset(
                    'assets/images/bottom_mainpage.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
                const SizedBox(width: 8),
                // Settings
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  child: Image.asset(
                    'assets/images/bottom_setting.png',
                    width: navHeight * 2.5,
                    height: navHeight * 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
