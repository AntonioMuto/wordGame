import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  
  NavigationBloc() : super(NavigationInitial()){
    on<NavigationChanged>((event, emit) async {
      if (event is NavigationChanged) {
        emit(NavigationChangedState(event.index)); 
      }
    });
  }
}
