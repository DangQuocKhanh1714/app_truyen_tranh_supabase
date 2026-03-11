abstract class SearchEvent {}

class OnQueryChanged extends SearchEvent {
  final String query;
  OnQueryChanged(this.query);
}

class ClearSearch extends SearchEvent {}