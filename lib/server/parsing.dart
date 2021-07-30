typedef JsonItemBuilder<T> = T Function(Map json);
List<T> parseJsonList<T>(List? jsonList, JsonItemBuilder<T> builder) {
  if (jsonList == null) {
    return [];
  }

  return List<T>.generate(jsonList.length, (index) => builder(jsonList[index]));
}

typedef JsonPrimitiveBuilder<T> = T Function(dynamic json);
List<T> parsePrimitiveList<T>(List jsonList, JsonPrimitiveBuilder<T> builder) {
  if (jsonList.isEmpty) {
    return [];
  }

  return List<T>.generate(jsonList.length, (index) => builder(jsonList[index]));
}

typedef CommaListParser<T> = T Function(String item);
List<T>? parseCommaList<T>(String? list, CommaListParser<T> parser) {
  if (list == null || list.isEmpty) return null;

  List<String> parts = list.split(",");
  return List.generate(parts.length, (index) => parser(parts[index]));
}
