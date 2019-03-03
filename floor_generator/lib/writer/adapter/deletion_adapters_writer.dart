import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/model/delete_method.dart';
import 'package:source_gen/source_gen.dart';

class DeletionAdaptersWriter {
  final LibraryReader library;
  final ClassBuilder builder;
  final List<DeleteMethod> deleteMethods;

  DeletionAdaptersWriter(this.library, this.builder, this.deleteMethods);

  void write() {
    final deleteEntities = deleteMethods
        .map((method) => method.getEntity(library))
        .where((entity) => entity != null)
        .toSet();

    for (final entity in deleteEntities) {
      final entityName = entity.name;

      final cacheName = '_${entityName}DeletionAdapterCache';
      final type = refer('DeletionAdapter<${entity.clazz.displayName}>');

      final adapterCache = Field((builder) => builder
        ..name = cacheName
        ..type = type);

      builder..fields.add(adapterCache);

      final valueMapper =
          '(${entity.clazz.displayName} item) => ${entity.getValueMapping(library)}';

      final getAdapter = Method((builder) => builder
        ..type = MethodType.getter
        ..name = '_${entityName}DeletionAdapter'
        ..returns = type
        ..body = Code('''
          return $cacheName ??= DeletionAdapter(database, '$entityName', '${entity.primaryKeyColumn.name}', $valueMapper);
        '''));

      builder..methods.add(getAdapter);
    }
  }
}