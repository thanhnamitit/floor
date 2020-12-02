import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotations.dart';
import 'package:floor_generator/writer/writer.dart';

class DatabaseBuilderWriter extends Writer {
  final String _databaseName;

  DatabaseBuilderWriter(final String databaseName)
      : _databaseName = databaseName;

  @nonNull
  @override
  Class write() {
    final databaseBuilderName = '_\$${_databaseName}Builder';

    final nameField = Field((builder) => builder
      ..name = 'name'
      ..type = refer('String')
      ..modifier = FieldModifier.final$);

    final passwordField = Field((builder) => builder
      ..name = '_password'
      ..type = refer('String'));

    final migrationsField = Field((builder) => builder
      ..name = '_migrations'
      ..type = refer('List<Migration>')
      ..modifier = FieldModifier.final$
      ..assignment = const Code('[]'));

    final callbackField = Field((builder) => builder
      ..name = '_callback'
      ..type = refer('Callback'));

    final constructor = Constructor((builder) => builder
      ..requiredParameters.add(Parameter((builder) => builder
        ..toThis = true
        ..name = 'name')));

    final addMigrationsMethod = Method((builder) => builder
      ..name = 'addMigrations'
      ..returns = refer(databaseBuilderName)
      ..body = const Code('''
        _migrations.addAll(migrations);
        return this;
      ''')
      ..docs.add('/// Adds migrations to the builder.')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'migrations'
        ..type = refer('List<Migration>'))));

    final addPasswordMethod = Method((builder) => builder
      ..name = 'addPassword'
      ..returns = refer(databaseBuilderName)
      ..body = const Code('''
        this._password = password;
        return this;
      ''')
      ..docs.add('/// Adds password to the builder.')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'password'
        ..type = refer('String'))));

    final addCallbackMethod = Method((builder) => builder
      ..name = 'addCallback'
      ..returns = refer(databaseBuilderName)
      ..body = const Code('''
        _callback = callback;
        return this;
      ''')
      ..docs.add('/// Adds a database [Callback] to the builder.')
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = 'callback'
        ..type = refer('Callback'))));

    final buildMethod = Method((builder) => builder
      ..returns = refer('Future<$_databaseName>')
      ..name = 'build'
      ..modifier = MethodModifier.async
      ..docs.add('/// Creates the database and initializes it.')
      ..body = Code('''
        final path = name != null
          ? await sqfliteDatabaseFactory.getDatabasePath(name)
          : ':memory:';
        final database = _\$$_databaseName();
        database.database = await database.open(
          path,
          _migrations,
          _callback,
          _password
        );
        return database;
      '''));

    return Class((builder) => builder
      ..name = databaseBuilderName
      ..fields.addAll([
        nameField,
        passwordField,
        migrationsField,
        callbackField,
      ])
      ..constructors.add(constructor)
      ..methods.addAll([
        addMigrationsMethod,
        addPasswordMethod,
        addCallbackMethod,
        buildMethod,
      ]));
  }
}