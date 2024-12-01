import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:word_game/core/ads/bloc/ads_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/home_page.dart';
import 'package:word_game/core/navigation/bloc/navigation_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(
          create: (_) => AdsBloc()..add(LoadBannerAdEvent()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SolveWords"),
          elevation: 0,
        ),
        body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: BlocBuilder<NavigationBloc, NavigationState>(builder: (context, state) {
          int selectedIndex = 0;
          if (state is NavigationChangedState) {
            selectedIndex = state.selectedIndex;
          }

          final List<Widget> _pages = [
            // BlocProvider per il HomeBloc, con evento LoadGameSectionsEvent emesso
            BlocProvider(
              create: (context) => HomeBloc()..add(LoadGameSectionsEvent()), 
              child: Column(
                children: [
                  Expanded(child: HomePage()),
                ],
              ),
            ),
            // Altre pagine
            Container(child: Text("CIAO2")),
            Container(child: Text("CIAO3")),
            Container(child: Text("CIAO4")),
          ];

          return _pages[selectedIndex]; // Restituisce la pagina selezionata
        }),
        ),
        bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            int selectedIndex = 0;
            if (state is NavigationChangedState) {
              selectedIndex = state.selectedIndex;
            }
            return Container(             

              decoration: const BoxDecoration(                                                   
                borderRadius: BorderRadius.only(                                           
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),            
                boxShadow: [                                                               
                  BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),       
                ],                                                                         
              ),     
              child: BottomNavigationBar(
                  currentIndex: selectedIndex,
                  elevation: 1,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color.fromARGB(255, 47, 47, 47),
                  selectedItemColor: Colors.amber[800],
                  selectedLabelStyle: const TextStyle(fontSize: 14),
                  selectedIconTheme: IconThemeData(size: 28),
                  unselectedIconTheme: IconThemeData(size: 18),
                  enableFeedback: false,
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  unselectedItemColor: Colors.white,
                  onTap: (index) {
                    context.read<NavigationBloc>().add(NavigationChanged(index));
                  },
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle),
                      label: 'Profilo',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications),
                      label: 'Notizie',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Impostazioni',
                    ),
                  ],
                  )
            );
          },
        ),
      ),
    );
  }
}
