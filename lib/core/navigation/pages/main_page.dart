import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/core/home/bloc/home_bloc.dart';
import 'package:word_game/core/home/pages/home_page.dart';
import 'package:word_game/core/navigation/bloc/navigation_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SolveWords"),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: BlocBuilder<NavigationBloc, NavigationState>(builder: (context, state) {
          int selectedIndex = 0;
          if (state is NavigationChangedState) {
            selectedIndex = state.selectedIndex;
          }

          final List<Widget> _pages = [
            // BlocProvider per il HomeBloc, con evento LoadGameSectionsEvent emesso
            BlocProvider(
              create: (context) => HomeBloc()..add(LoadGameSectionsEvent()), 
              child: HomePage(),
            ),
            // Altre pagine
            Container(child: Text("CIAO2")),
            Container(child: Text("CIAO3")),
            Container(child: Text("CIAO4")),
          ];

          return _pages[selectedIndex]; // Restituisce la pagina selezionata
        }),
        bottomNavigationBar: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            int selectedIndex = 0;
            if (state is NavigationChangedState) {
              selectedIndex = state.selectedIndex;
            }

            return BottomNavigationBar(
              currentIndex: selectedIndex,
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
            );
          },
        ),
      ),
    );
  }
}
