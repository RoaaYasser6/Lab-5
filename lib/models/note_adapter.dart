
import 'package:day5/models/note.dart';
import 'package:hive/hive.dart';

class NoteAdapter extends TypeAdapter<Note> {
  @override
  int get typeId => 0;

  //   @override
  // final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    // return Note(reader.readInt(), reader.readString(), reader.readString());
    return Note(
      id: reader.read(),
      title: reader.read(),
      description: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
  }
}
