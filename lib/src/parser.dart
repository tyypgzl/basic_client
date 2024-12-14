abstract interface class BasicRequestParser {
  Map<String, dynamic> toJson();
}

abstract interface class BasicResponseParser<T> {
  T fromJson(Map<String, dynamic> json);
}

abstract interface class BasicParser<T>
    implements BasicRequestParser, BasicResponseParser<T> {
  @override
  Map<String, dynamic> toJson();
  @override
  T fromJson(Map<String, dynamic> json);
}
