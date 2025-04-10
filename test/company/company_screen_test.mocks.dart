// Mocks generated by Mockito 5.4.5 from annotations
// in judeh_accounting/test/company/company_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i8;

import 'package:get/get.dart' as _i2;
import 'package:get/get_state_manager/src/simple/list_notifier.dart' as _i7;
import 'package:judeh_accounting/company/controllers/company_controller.dart'
    as _i5;
import 'package:judeh_accounting/company/models/company.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i9;
import 'package:sqflite_common/sql.dart' as _i10;
import 'package:sqflite_common/sqlite_api.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeRxList_0<E> extends _i1.SmartFake implements _i2.RxList<E> {
  _FakeRxList_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeInternalFinalCallback_1<T> extends _i1.SmartFake
    implements _i2.InternalFinalCallback<T> {
  _FakeInternalFinalCallback_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeDatabase_2 extends _i1.SmartFake implements _i3.Database {
  _FakeDatabase_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFuture_3<T1> extends _i1.SmartFake implements _i4.Future<T1> {
  _FakeFuture_3(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeQueryCursor_4 extends _i1.SmartFake implements _i3.QueryCursor {
  _FakeQueryCursor_4(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBatch_5 extends _i1.SmartFake implements _i3.Batch {
  _FakeBatch_5(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [CompanyController].
///
/// See the documentation for Mockito's code generation for more information.
class MockCompanyController extends _i1.Mock implements _i5.CompanyController {
  @override
  _i2.RxList<_i6.Company> get companies =>
      (super.noSuchMethod(
            Invocation.getter(#companies),
            returnValue: _FakeRxList_0<_i6.Company>(
              this,
              Invocation.getter(#companies),
            ),
            returnValueForMissingStub: _FakeRxList_0<_i6.Company>(
              this,
              Invocation.getter(#companies),
            ),
          )
          as _i2.RxList<_i6.Company>);

  @override
  int get selectedIndex =>
      (super.noSuchMethod(
            Invocation.getter(#selectedIndex),
            returnValue: 0,
            returnValueForMissingStub: 0,
          )
          as int);

  @override
  set selectedIndex(int? _selectedIndex) => super.noSuchMethod(
    Invocation.setter(#selectedIndex, _selectedIndex),
    returnValueForMissingStub: null,
  );

  @override
  _i2.InternalFinalCallback<void> get onStart =>
      (super.noSuchMethod(
            Invocation.getter(#onStart),
            returnValue: _FakeInternalFinalCallback_1<void>(
              this,
              Invocation.getter(#onStart),
            ),
            returnValueForMissingStub: _FakeInternalFinalCallback_1<void>(
              this,
              Invocation.getter(#onStart),
            ),
          )
          as _i2.InternalFinalCallback<void>);

  @override
  _i2.InternalFinalCallback<void> get onDelete =>
      (super.noSuchMethod(
            Invocation.getter(#onDelete),
            returnValue: _FakeInternalFinalCallback_1<void>(
              this,
              Invocation.getter(#onDelete),
            ),
            returnValueForMissingStub: _FakeInternalFinalCallback_1<void>(
              this,
              Invocation.getter(#onDelete),
            ),
          )
          as _i2.InternalFinalCallback<void>);

  @override
  bool get initialized =>
      (super.noSuchMethod(
            Invocation.getter(#initialized),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get isClosed =>
      (super.noSuchMethod(
            Invocation.getter(#isClosed),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(
            Invocation.getter(#hasListeners),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  int get listeners =>
      (super.noSuchMethod(
            Invocation.getter(#listeners),
            returnValue: 0,
            returnValueForMissingStub: 0,
          )
          as int);

  @override
  void onClose() => super.noSuchMethod(
    Invocation.method(#onClose, []),
    returnValueForMissingStub: null,
  );

  @override
  void onInit() => super.noSuchMethod(
    Invocation.method(#onInit, []),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Future<void> getData() =>
      (super.noSuchMethod(
            Invocation.method(#getData, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> create() =>
      (super.noSuchMethod(
            Invocation.method(#create, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> edit() =>
      (super.noSuchMethod(
            Invocation.method(#edit, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void update([List<Object>? ids, bool? condition = true]) =>
      super.noSuchMethod(
        Invocation.method(#update, [ids, condition]),
        returnValueForMissingStub: null,
      );

  @override
  void onReady() => super.noSuchMethod(
    Invocation.method(#onReady, []),
    returnValueForMissingStub: null,
  );

  @override
  void $configureLifeCycle() => super.noSuchMethod(
    Invocation.method(#$configureLifeCycle, []),
    returnValueForMissingStub: null,
  );

  @override
  _i7.Disposer addListener(_i7.GetStateUpdate? listener) =>
      (super.noSuchMethod(
            Invocation.method(#addListener, [listener]),
            returnValue: () {},
            returnValueForMissingStub: () {},
          )
          as _i7.Disposer);

  @override
  void removeListener(_i8.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void refresh() => super.noSuchMethod(
    Invocation.method(#refresh, []),
    returnValueForMissingStub: null,
  );

  @override
  void refreshGroup(Object? id) => super.noSuchMethod(
    Invocation.method(#refreshGroup, [id]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyChildrens() => super.noSuchMethod(
    Invocation.method(#notifyChildrens, []),
    returnValueForMissingStub: null,
  );

  @override
  void removeListenerId(Object? id, _i8.VoidCallback? listener) =>
      super.noSuchMethod(
        Invocation.method(#removeListenerId, [id, listener]),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  _i7.Disposer addListenerId(Object? key, _i7.GetStateUpdate? listener) =>
      (super.noSuchMethod(
            Invocation.method(#addListenerId, [key, listener]),
            returnValue: () {},
            returnValueForMissingStub: () {},
          )
          as _i7.Disposer);

  @override
  void disposeId(Object? id) => super.noSuchMethod(
    Invocation.method(#disposeId, [id]),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [Database].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabase extends _i1.Mock implements _i3.Database {
  @override
  String get path =>
      (super.noSuchMethod(
            Invocation.getter(#path),
            returnValue: _i9.dummyValue<String>(this, Invocation.getter(#path)),
            returnValueForMissingStub: _i9.dummyValue<String>(
              this,
              Invocation.getter(#path),
            ),
          )
          as String);

  @override
  bool get isOpen =>
      (super.noSuchMethod(
            Invocation.getter(#isOpen),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  _i3.Database get database =>
      (super.noSuchMethod(
            Invocation.getter(#database),
            returnValue: _FakeDatabase_2(this, Invocation.getter(#database)),
            returnValueForMissingStub: _FakeDatabase_2(
              this,
              Invocation.getter(#database),
            ),
          )
          as _i3.Database);

  @override
  _i4.Future<void> close() =>
      (super.noSuchMethod(
            Invocation.method(#close, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<T> transaction<T>(
    _i4.Future<T> Function(_i3.Transaction)? action, {
    bool? exclusive,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#transaction, [action], {#exclusive: exclusive}),
            returnValue:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(
                      #transaction,
                      [action],
                      {#exclusive: exclusive},
                    ),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(
                    #transaction,
                    [action],
                    {#exclusive: exclusive},
                  ),
                ),
            returnValueForMissingStub:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(
                      #transaction,
                      [action],
                      {#exclusive: exclusive},
                    ),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(
                    #transaction,
                    [action],
                    {#exclusive: exclusive},
                  ),
                ),
          )
          as _i4.Future<T>);

  @override
  _i4.Future<T> readTransaction<T>(
    _i4.Future<T> Function(_i3.Transaction)? action,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#readTransaction, [action]),
            returnValue:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(#readTransaction, [action]),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(#readTransaction, [action]),
                ),
            returnValueForMissingStub:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(#readTransaction, [action]),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(#readTransaction, [action]),
                ),
          )
          as _i4.Future<T>);

  @override
  _i4.Future<T> devInvokeMethod<T>(String? method, [Object? arguments]) =>
      (super.noSuchMethod(
            Invocation.method(#devInvokeMethod, [method, arguments]),
            returnValue:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(#devInvokeMethod, [method, arguments]),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(#devInvokeMethod, [method, arguments]),
                ),
            returnValueForMissingStub:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(#devInvokeMethod, [method, arguments]),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(#devInvokeMethod, [method, arguments]),
                ),
          )
          as _i4.Future<T>);

  @override
  _i4.Future<T> devInvokeSqlMethod<T>(
    String? method,
    String? sql, [
    List<Object?>? arguments,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#devInvokeSqlMethod, [method, sql, arguments]),
            returnValue:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(#devInvokeSqlMethod, [
                      method,
                      sql,
                      arguments,
                    ]),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(#devInvokeSqlMethod, [
                    method,
                    sql,
                    arguments,
                  ]),
                ),
            returnValueForMissingStub:
                _i9.ifNotNull(
                  _i9.dummyValueOrNull<T>(
                    this,
                    Invocation.method(#devInvokeSqlMethod, [
                      method,
                      sql,
                      arguments,
                    ]),
                  ),
                  (T v) => _i4.Future<T>.value(v),
                ) ??
                _FakeFuture_3<T>(
                  this,
                  Invocation.method(#devInvokeSqlMethod, [
                    method,
                    sql,
                    arguments,
                  ]),
                ),
          )
          as _i4.Future<T>);

  @override
  _i4.Future<void> execute(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(
            Invocation.method(#execute, [sql, arguments]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<int> rawInsert(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(
            Invocation.method(#rawInsert, [sql, arguments]),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i4.Future<int> insert(
    String? table,
    Map<String, Object?>? values, {
    String? nullColumnHack,
    _i10.ConflictAlgorithm? conflictAlgorithm,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #insert,
              [table, values],
              {
                #nullColumnHack: nullColumnHack,
                #conflictAlgorithm: conflictAlgorithm,
              },
            ),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i4.Future<List<Map<String, Object?>>> query(
    String? table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #query,
              [table],
              {
                #distinct: distinct,
                #columns: columns,
                #where: where,
                #whereArgs: whereArgs,
                #groupBy: groupBy,
                #having: having,
                #orderBy: orderBy,
                #limit: limit,
                #offset: offset,
              },
            ),
            returnValue: _i4.Future<List<Map<String, Object?>>>.value(
              <Map<String, Object?>>[],
            ),
            returnValueForMissingStub:
                _i4.Future<List<Map<String, Object?>>>.value(
                  <Map<String, Object?>>[],
                ),
          )
          as _i4.Future<List<Map<String, Object?>>>);

  @override
  _i4.Future<List<Map<String, Object?>>> rawQuery(
    String? sql, [
    List<Object?>? arguments,
  ]) =>
      (super.noSuchMethod(
            Invocation.method(#rawQuery, [sql, arguments]),
            returnValue: _i4.Future<List<Map<String, Object?>>>.value(
              <Map<String, Object?>>[],
            ),
            returnValueForMissingStub:
                _i4.Future<List<Map<String, Object?>>>.value(
                  <Map<String, Object?>>[],
                ),
          )
          as _i4.Future<List<Map<String, Object?>>>);

  @override
  _i4.Future<_i3.QueryCursor> rawQueryCursor(
    String? sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #rawQueryCursor,
              [sql, arguments],
              {#bufferSize: bufferSize},
            ),
            returnValue: _i4.Future<_i3.QueryCursor>.value(
              _FakeQueryCursor_4(
                this,
                Invocation.method(
                  #rawQueryCursor,
                  [sql, arguments],
                  {#bufferSize: bufferSize},
                ),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i3.QueryCursor>.value(
              _FakeQueryCursor_4(
                this,
                Invocation.method(
                  #rawQueryCursor,
                  [sql, arguments],
                  {#bufferSize: bufferSize},
                ),
              ),
            ),
          )
          as _i4.Future<_i3.QueryCursor>);

  @override
  _i4.Future<_i3.QueryCursor> queryCursor(
    String? table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #queryCursor,
              [table],
              {
                #distinct: distinct,
                #columns: columns,
                #where: where,
                #whereArgs: whereArgs,
                #groupBy: groupBy,
                #having: having,
                #orderBy: orderBy,
                #limit: limit,
                #offset: offset,
                #bufferSize: bufferSize,
              },
            ),
            returnValue: _i4.Future<_i3.QueryCursor>.value(
              _FakeQueryCursor_4(
                this,
                Invocation.method(
                  #queryCursor,
                  [table],
                  {
                    #distinct: distinct,
                    #columns: columns,
                    #where: where,
                    #whereArgs: whereArgs,
                    #groupBy: groupBy,
                    #having: having,
                    #orderBy: orderBy,
                    #limit: limit,
                    #offset: offset,
                    #bufferSize: bufferSize,
                  },
                ),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i3.QueryCursor>.value(
              _FakeQueryCursor_4(
                this,
                Invocation.method(
                  #queryCursor,
                  [table],
                  {
                    #distinct: distinct,
                    #columns: columns,
                    #where: where,
                    #whereArgs: whereArgs,
                    #groupBy: groupBy,
                    #having: having,
                    #orderBy: orderBy,
                    #limit: limit,
                    #offset: offset,
                    #bufferSize: bufferSize,
                  },
                ),
              ),
            ),
          )
          as _i4.Future<_i3.QueryCursor>);

  @override
  _i4.Future<int> rawUpdate(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(
            Invocation.method(#rawUpdate, [sql, arguments]),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i4.Future<int> update(
    String? table,
    Map<String, Object?>? values, {
    String? where,
    List<Object?>? whereArgs,
    _i10.ConflictAlgorithm? conflictAlgorithm,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #update,
              [table, values],
              {
                #where: where,
                #whereArgs: whereArgs,
                #conflictAlgorithm: conflictAlgorithm,
              },
            ),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i4.Future<int> rawDelete(String? sql, [List<Object?>? arguments]) =>
      (super.noSuchMethod(
            Invocation.method(#rawDelete, [sql, arguments]),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i4.Future<int> delete(
    String? table, {
    String? where,
    List<Object?>? whereArgs,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [table],
              {#where: where, #whereArgs: whereArgs},
            ),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i3.Batch batch() =>
      (super.noSuchMethod(
            Invocation.method(#batch, []),
            returnValue: _FakeBatch_5(this, Invocation.method(#batch, [])),
            returnValueForMissingStub: _FakeBatch_5(
              this,
              Invocation.method(#batch, []),
            ),
          )
          as _i3.Batch);
}
