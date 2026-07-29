import 'dart:async';

import 'package:mockito/mockito.dart';

extension PostExpectationX<T> on PostExpectation<Future<T>> {
  void thenReturnAsync(FutureOr<T> expected) =>
      thenAnswer((_) => .value(expected));
}
