import 'package:flutter_test/flutter_test.dart';
import 'package:tagteamprod/models/message.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

void main() {
  group('Testing message sorting', () {
    test('When day of next message is different from current it should be shown', () {
      // Arrange

      Message currentMessage = new Message(createdAt: DateTime.now());
      Message nextDayMessage = new Message(createdAt: DateTime(2021, 8, 31));

      late bool isDifferentDay;

      // Act // Refactor using actual function

      isDifferentDay = currentMessage.createdAt!.isSameDate(nextDayMessage.createdAt!);

      // Assert

      expect(isDifferentDay, false);
    });
  });
}
