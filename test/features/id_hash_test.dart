import 'package:dart_tools/features.dart';
import 'package:test/test.dart';

final id1 = PartId(["1", "2", "3"]);
final id2 = PartId(["1", "2", "3"]);
final id3 = PartId(["1", "2", "3", "4"]);

void main() {
  group("Testing ID hashing", () {
    test("Comparing", () {
      expect(id1 == id2, true);
      // print(id1 == id2);
      // expect(id1.hashCode == id2.hashCode, true);
    },);
  },);
}