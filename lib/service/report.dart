class Report {
  factory Report() => _instance ??= Report._();

  Report._();
  static Report? _instance;

  Future<dynamic> createReport()async{
    // do something
  }

}
