import 'dart:async';

import 'package:mockito/mockito.dart';

extension PostExpectationFutureX<T> on PostExpectation<Future<T>> {
  void thenReturnAsync(FutureOr<T> expected) =>
      thenAnswer((_) => .value(expected));
}

extension PostExpectationStreamX<T> on PostExpectation<Stream<T>> {
  void thenStream(Stream<T> expected) => thenAnswer((_) => expected);
}
