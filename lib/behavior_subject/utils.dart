class _Empty {
  const _Empty();

  @override
  String toString() => '<<EMPTY>>';
}

T? unbox<T>(Object? o) => identical(o, EMPTY) ? null : o as T;

const Object? EMPTY = _Empty(); // ignore: constant_identifier_names

bool isNotEmpty(Object? o) => !identical(o, EMPTY);
