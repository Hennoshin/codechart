enum DataType {
  integer,
  real,
  boolean,
  string
}

const Map<DataType, Type> dataTypeMap = {
  DataType.integer: int,
  DataType.real: double,
  DataType.boolean: bool,
  DataType.string: String
};

class Wrapper<T> {
  T? val;
  Type type = T;

  Wrapper([this.val]);

  T? get value => val;
  set value(T? src) => val = src;
}

class ListWrapper<T> extends Wrapper<List<Wrapper<T>>> {
  ListWrapper(int size) : super(List<Wrapper<T>>.filled(size, Wrapper<T>()));
}