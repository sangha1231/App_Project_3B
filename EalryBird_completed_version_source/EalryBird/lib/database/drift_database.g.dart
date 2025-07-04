
part of 'drift_database.dart';

// ignore_for_file: type=lint
class $SchedulesTable extends Schedules with TableInfo<$SchedulesTable, Schedule>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$SchedulesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _contentMeta = const VerificationMeta('content');
@override
late final GeneratedColumn<String> content = GeneratedColumn<String>('content', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _dateMeta = const VerificationMeta('date');
@override
late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _startTimeMeta = const VerificationMeta('startTime');
@override
late final GeneratedColumn<int> startTime = GeneratedColumn<int>('start_time', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _endTimeMeta = const VerificationMeta('endTime');
@override
late final GeneratedColumn<int> endTime = GeneratedColumn<int>('end_time', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, content, date, startTime, endTime];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'schedules';
@override
VerificationContext validateIntegrity(Insertable<Schedule> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('content')) {
context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));} else if (isInserting) {
context.missing(_contentMeta);
}
if (data.containsKey('date')) {
context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));} else if (isInserting) {
context.missing(_dateMeta);
}
if (data.containsKey('start_time')) {
context.handle(_startTimeMeta, startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));} else if (isInserting) {
context.missing(_startTimeMeta);
}
if (data.containsKey('end_time')) {
context.handle(_endTimeMeta, endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));} else if (isInserting) {
context.missing(_endTimeMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Schedule map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Schedule(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, content: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}content'])!, date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!, startTime: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}start_time'])!, endTime: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}end_time'])!, );
}
@override
$SchedulesTable createAlias(String alias) {
return $SchedulesTable(attachedDatabase, alias);}}class Schedule extends DataClass implements Insertable<Schedule> 
{
final int id;
final String content;
final DateTime date;
final int startTime;
final int endTime;
const Schedule({required this.id, required this.content, required this.date, required this.startTime, required this.endTime});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['content'] = Variable<String>(content);
map['date'] = Variable<DateTime>(date);
map['start_time'] = Variable<int>(startTime);
map['end_time'] = Variable<int>(endTime);
return map; 
}
SchedulesCompanion toCompanion(bool nullToAbsent) {
return SchedulesCompanion(id: Value(id),content: Value(content),date: Value(date),startTime: Value(startTime),endTime: Value(endTime),);
}
factory Schedule.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Schedule(id: serializer.fromJson<int>(json['id']),content: serializer.fromJson<String>(json['content']),date: serializer.fromJson<DateTime>(json['date']),startTime: serializer.fromJson<int>(json['startTime']),endTime: serializer.fromJson<int>(json['endTime']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'content': serializer.toJson<String>(content),'date': serializer.toJson<DateTime>(date),'startTime': serializer.toJson<int>(startTime),'endTime': serializer.toJson<int>(endTime),};}Schedule copyWith({int? id,String? content,DateTime? date,int? startTime,int? endTime}) => Schedule(id: id ?? this.id,content: content ?? this.content,date: date ?? this.date,startTime: startTime ?? this.startTime,endTime: endTime ?? this.endTime,);Schedule copyWithCompanion(SchedulesCompanion data) {
return Schedule(
id: data.id.present ? data.id.value : this.id,content: data.content.present ? data.content.value : this.content,date: data.date.present ? data.date.value : this.date,startTime: data.startTime.present ? data.startTime.value : this.startTime,endTime: data.endTime.present ? data.endTime.value : this.endTime,);
}
@override
String toString() {return (StringBuffer('Schedule(')..write('id: $id, ')..write('content: $content, ')..write('date: $date, ')..write('startTime: $startTime, ')..write('endTime: $endTime')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, content, date, startTime, endTime);@override
bool operator ==(Object other) => identical(this, other) || (other is Schedule && other.id == this.id && other.content == this.content && other.date == this.date && other.startTime == this.startTime && other.endTime == this.endTime);
}class SchedulesCompanion extends UpdateCompanion<Schedule> {
final Value<int> id;
final Value<String> content;
final Value<DateTime> date;
final Value<int> startTime;
final Value<int> endTime;
const SchedulesCompanion({this.id = const Value.absent(),this.content = const Value.absent(),this.date = const Value.absent(),this.startTime = const Value.absent(),this.endTime = const Value.absent(),});
SchedulesCompanion.insert({this.id = const Value.absent(),required String content,required DateTime date,required int startTime,required int endTime,}): content = Value(content), date = Value(date), startTime = Value(startTime), endTime = Value(endTime);
static Insertable<Schedule> custom({Expression<int>? id, 
Expression<String>? content, 
Expression<DateTime>? date, 
Expression<int>? startTime, 
Expression<int>? endTime, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (content != null)'content': content,if (date != null)'date': date,if (startTime != null)'start_time': startTime,if (endTime != null)'end_time': endTime,});
}SchedulesCompanion copyWith({Value<int>? id, Value<String>? content, Value<DateTime>? date, Value<int>? startTime, Value<int>? endTime}) {
return SchedulesCompanion(id: id ?? this.id,content: content ?? this.content,date: date ?? this.date,startTime: startTime ?? this.startTime,endTime: endTime ?? this.endTime,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (content.present) {
map['content'] = Variable<String>(content.value);}
if (date.present) {
map['date'] = Variable<DateTime>(date.value);}
if (startTime.present) {
map['start_time'] = Variable<int>(startTime.value);}
if (endTime.present) {
map['end_time'] = Variable<int>(endTime.value);}
return map; 
}
@override
String toString() {return (StringBuffer('SchedulesCompanion(')..write('id: $id, ')..write('content: $content, ')..write('date: $date, ')..write('startTime: $startTime, ')..write('endTime: $endTime')..write(')')).toString();}
}
abstract class _$LocalDatabase extends GeneratedDatabase{
_$LocalDatabase(QueryExecutor e): super(e);
$LocalDatabaseManager get managers => $LocalDatabaseManager(this);
late final $SchedulesTable schedules = $SchedulesTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [schedules];
}
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({Value<int> id,required String content,required DateTime date,required int startTime,required int endTime,});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({Value<int> id,Value<String> content,Value<DateTime> date,Value<int> startTime,Value<int> endTime,});
class $$SchedulesTableFilterComposer extends Composer<
        _$LocalDatabase,
        $SchedulesTable> {
        $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<int> get startTime => $composableBuilder(
      column: $table.startTime,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<int> get endTime => $composableBuilder(
      column: $table.endTime,
      builder: (column) =>
      ColumnFilters(column));
      
        }
      class $$SchedulesTableOrderingComposer extends Composer<
        _$LocalDatabase,
        $SchedulesTable> {
        $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<int> get startTime => $composableBuilder(
      column: $table.startTime,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<int> get endTime => $composableBuilder(
      column: $table.endTime,
      builder: (column) =>
      ColumnOrderings(column));
      
        }
      class $$SchedulesTableAnnotationComposer extends Composer<
        _$LocalDatabase,
        $SchedulesTable> {
        $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get date => $composableBuilder(
      column: $table.date,
      builder: (column) => column);
      
GeneratedColumn<int> get startTime => $composableBuilder(
      column: $table.startTime,
      builder: (column) => column);
      
GeneratedColumn<int> get endTime => $composableBuilder(
      column: $table.endTime,
      builder: (column) => column);
      
        }
      class $$SchedulesTableTableManager extends RootTableManager    <_$LocalDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule,BaseReferences<_$LocalDatabase,$SchedulesTable,Schedule>),
    Schedule,
    PrefetchHooks Function()
    > {
    $$SchedulesTableTableManager(_$LocalDatabase db, $SchedulesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$SchedulesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$SchedulesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$SchedulesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> content = const Value.absent(),Value<DateTime> date = const Value.absent(),Value<int> startTime = const Value.absent(),Value<int> endTime = const Value.absent(),})=> SchedulesCompanion(id: id,content: content,date: date,startTime: startTime,endTime: endTime,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String content,required DateTime date,required int startTime,required int endTime,})=> SchedulesCompanion.insert(id: id,content: content,date: date,startTime: startTime,endTime: endTime,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager    <_$LocalDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule,BaseReferences<_$LocalDatabase,$SchedulesTable,Schedule>),
    Schedule,
    PrefetchHooks Function()
    >;class $LocalDatabaseManager {
final _$LocalDatabase _db;
$LocalDatabaseManager(this._db);
$$SchedulesTableTableManager get schedules => $$SchedulesTableTableManager(_db, _db.schedules);
}
