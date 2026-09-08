import 'db_factory_stub.dart'
    if (dart.library.io) 'db_factory_io.dart' as impl;

void initDatabaseFactory() => impl.initFactoryImpl();
