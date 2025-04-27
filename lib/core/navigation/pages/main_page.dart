import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/home_page.dart';
import 'package:word_game/core/navigation/bloc/navigation_bloc.dart';
import 'package:word_game/core/profile/profile_bloc.dart';
import 'package:word_game/core/theme/bloc/theme_bloc.dart';

import '../../theme/bloc/theme_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => ThemeBloc()), // BlocProvider per il tema
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(create: (context) => AdsBloc()..add(LoadBannerAdEvent())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.themeData, // Applica il tema dinamico a tutta l'app
            home: const MainPage(), // Home page dell'app
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(
            create: (context) => AdsBloc()
              ..add(LoadBannerAdEvent())), // <-- Add AdsBloc provider here
        BlocProvider(
            create: (context) => ProfileBloc()..add(FetchProfileData())),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: const Color.fromARGB(255, 80, 80, 80)))),
                  child: const _CustomAppBar()),
              Expanded(
                child: _getPageForIndex(_selectedIndex),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AdBannerContainer(),
            _buildBottomNavigationBar(Theme.of(context)),
          ],
        ),
      ),
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return BlocProvider(
          create: (_) => HomeBloc()..add(LoadGameSectionsEvent()),
          child: const HomePage(),
        );
      case 1:
        return const Center(child: Text("👤 Profilo"));
      case 2:
        return const Center(child: Text("📰 Notizie"));
      case 3:
        return const Center(child: Text("⚙️ Impostazioni"));
      default:
        return const Center(child: Text("Pagina non trovata"));
    }
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 80, 80, 80), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 80, 80, 80), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 80, 80, 80), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAnimatedNavItem(Icons.home, "Home", 0),
          _buildAnimatedNavItem(Icons.grid_view, "Livelli", 1),
          _buildAnimatedNavItem(Icons.star, "Bonus", 2),
          _buildAnimatedNavItem(Icons.settings, "Impostazioni", 3),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColorDark
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            ),
          ),
          child: isSelected
              ? Row(
                  key: const ValueKey('selected'),
                  children: [
                    Icon(icon, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                )
              : Icon(
                  icon,
                  key: const ValueKey('unselected'),
                  color: Theme.of(context).primaryColorDark,
                ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        print(state);
        if (state is ProfileLoaded) {
          var profileData = state;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bottone per cambiare il tema
                IconButton(
                  icon: Icon(
                    Icons.brightness_6,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    // Determina il tema corrente
                    final currentTheme = BlocProvider.of<ThemeBloc>(context)
                        .state
                        .themeData
                        .brightness;

                    // Cambia tema
                    if (currentTheme == Brightness.dark) {
                      BlocProvider.of<ThemeBloc>(context)
                          .add(ThemeEvent.toggleLight); // Tema chiaro
                    } else {
                      BlocProvider.of<ThemeBloc>(context)
                          .add(ThemeEvent.toggleDark); // Tema scuro
                    }
                  },
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.person,
                          color: Theme.of(context).primaryColorDark),
                    ),
                  ],
                ),
                Text(
                  profileData.username ?? '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color ??
                        Colors.grey[900],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber[700]!, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on,
                          color: Colors.amber[700], size: 20),
                      SizedBox(width: 6),
                      Text(profileData.token.toString(),
                          style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AdBannerContainer extends StatelessWidget {
  const _AdBannerContainer();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, adsState) {
        if (adsState is BannerAdLoaded) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: adsState.bannerAd.size.height.toDouble(),
            width: adsState.bannerAd.size.width.toDouble(),
            child: AdWidget(ad: adsState.bannerAd),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
