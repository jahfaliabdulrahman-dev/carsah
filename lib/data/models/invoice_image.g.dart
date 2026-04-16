// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_image.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvoiceImageCollection on Isar {
  IsarCollection<InvoiceImage> get invoiceImages => this.collection();
}

const InvoiceImageSchema = CollectionSchema(
  name: r'InvoiceImage',
  id: -666632089465883353,
  properties: {
    r'contentHash': PropertySchema(
      id: 0,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fileSizeBytes': PropertySchema(
      id: 2,
      name: r'fileSizeBytes',
      type: IsarType.long,
    ),
    r'refCount': PropertySchema(
      id: 3,
      name: r'refCount',
      type: IsarType.long,
    ),
    r'relativePath': PropertySchema(
      id: 4,
      name: r'relativePath',
      type: IsarType.string,
    )
  },
  estimateSize: _invoiceImageEstimateSize,
  serialize: _invoiceImageSerialize,
  deserialize: _invoiceImageDeserialize,
  deserializeProp: _invoiceImageDeserializeProp,
  idName: r'id',
  indexes: {
    r'contentHash': IndexSchema(
      id: -8004451629925743238,
      name: r'contentHash',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'contentHash',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _invoiceImageGetId,
  getLinks: _invoiceImageGetLinks,
  attach: _invoiceImageAttach,
  version: '3.1.0+1',
);

int _invoiceImageEstimateSize(
  InvoiceImage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.contentHash.length * 3;
  bytesCount += 3 + object.relativePath.length * 3;
  return bytesCount;
}

void _invoiceImageSerialize(
  InvoiceImage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.contentHash);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.fileSizeBytes);
  writer.writeLong(offsets[3], object.refCount);
  writer.writeString(offsets[4], object.relativePath);
}

InvoiceImage _invoiceImageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvoiceImage(
    contentHash: reader.readString(offsets[0]),
    fileSizeBytes: reader.readLongOrNull(offsets[2]) ?? 0,
    refCount: reader.readLongOrNull(offsets[3]) ?? 1,
    relativePath: reader.readString(offsets[4]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  return object;
}

P _invoiceImageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _invoiceImageGetId(InvoiceImage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _invoiceImageGetLinks(InvoiceImage object) {
  return [];
}

void _invoiceImageAttach(
    IsarCollection<dynamic> col, Id id, InvoiceImage object) {
  object.id = id;
}

extension InvoiceImageByIndex on IsarCollection<InvoiceImage> {
  Future<InvoiceImage?> getByContentHash(String contentHash) {
    return getByIndex(r'contentHash', [contentHash]);
  }

  InvoiceImage? getByContentHashSync(String contentHash) {
    return getByIndexSync(r'contentHash', [contentHash]);
  }

  Future<bool> deleteByContentHash(String contentHash) {
    return deleteByIndex(r'contentHash', [contentHash]);
  }

  bool deleteByContentHashSync(String contentHash) {
    return deleteByIndexSync(r'contentHash', [contentHash]);
  }

  Future<List<InvoiceImage?>> getAllByContentHash(
      List<String> contentHashValues) {
    final values = contentHashValues.map((e) => [e]).toList();
    return getAllByIndex(r'contentHash', values);
  }

  List<InvoiceImage?> getAllByContentHashSync(List<String> contentHashValues) {
    final values = contentHashValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'contentHash', values);
  }

  Future<int> deleteAllByContentHash(List<String> contentHashValues) {
    final values = contentHashValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'contentHash', values);
  }

  int deleteAllByContentHashSync(List<String> contentHashValues) {
    final values = contentHashValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'contentHash', values);
  }

  Future<Id> putByContentHash(InvoiceImage object) {
    return putByIndex(r'contentHash', object);
  }

  Id putByContentHashSync(InvoiceImage object, {bool saveLinks = true}) {
    return putByIndexSync(r'contentHash', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByContentHash(List<InvoiceImage> objects) {
    return putAllByIndex(r'contentHash', objects);
  }

  List<Id> putAllByContentHashSync(List<InvoiceImage> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'contentHash', objects, saveLinks: saveLinks);
  }
}

extension InvoiceImageQueryWhereSort
    on QueryBuilder<InvoiceImage, InvoiceImage, QWhere> {
  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InvoiceImageQueryWhere
    on QueryBuilder<InvoiceImage, InvoiceImage, QWhereClause> {
  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause>
      contentHashEqualTo(String contentHash) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'contentHash',
        value: [contentHash],
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterWhereClause>
      contentHashNotEqualTo(String contentHash) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentHash',
              lower: [],
              upper: [contentHash],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentHash',
              lower: [contentHash],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentHash',
              lower: [contentHash],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentHash',
              lower: [],
              upper: [contentHash],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InvoiceImageQueryFilter
    on QueryBuilder<InvoiceImage, InvoiceImage, QFilterCondition> {
  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      fileSizeBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      fileSizeBytesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      fileSizeBytesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      fileSizeBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSizeBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      refCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refCount',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      refCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refCount',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      refCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refCount',
        value: value,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      refCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relativePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relativePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relativePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relativePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relativePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relativePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relativePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relativePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relativePath',
        value: '',
      ));
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterFilterCondition>
      relativePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relativePath',
        value: '',
      ));
    });
  }
}

extension InvoiceImageQueryObject
    on QueryBuilder<InvoiceImage, InvoiceImage, QFilterCondition> {}

extension InvoiceImageQueryLinks
    on QueryBuilder<InvoiceImage, InvoiceImage, QFilterCondition> {}

extension InvoiceImageQuerySortBy
    on QueryBuilder<InvoiceImage, InvoiceImage, QSortBy> {
  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy>
      sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy>
      sortByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByRefCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refCount', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByRefCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refCount', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> sortByRelativePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativePath', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy>
      sortByRelativePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativePath', Sort.desc);
    });
  }
}

extension InvoiceImageQuerySortThenBy
    on QueryBuilder<InvoiceImage, InvoiceImage, QSortThenBy> {
  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy>
      thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy>
      thenByFileSizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSizeBytes', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByRefCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refCount', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByRefCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refCount', Sort.desc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy> thenByRelativePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativePath', Sort.asc);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QAfterSortBy>
      thenByRelativePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relativePath', Sort.desc);
    });
  }
}

extension InvoiceImageQueryWhereDistinct
    on QueryBuilder<InvoiceImage, InvoiceImage, QDistinct> {
  QueryBuilder<InvoiceImage, InvoiceImage, QDistinct> distinctByContentHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QDistinct>
      distinctByFileSizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSizeBytes');
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QDistinct> distinctByRefCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refCount');
    });
  }

  QueryBuilder<InvoiceImage, InvoiceImage, QDistinct> distinctByRelativePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relativePath', caseSensitive: caseSensitive);
    });
  }
}

extension InvoiceImageQueryProperty
    on QueryBuilder<InvoiceImage, InvoiceImage, QQueryProperty> {
  QueryBuilder<InvoiceImage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvoiceImage, String, QQueryOperations> contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<InvoiceImage, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InvoiceImage, int, QQueryOperations> fileSizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSizeBytes');
    });
  }

  QueryBuilder<InvoiceImage, int, QQueryOperations> refCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refCount');
    });
  }

  QueryBuilder<InvoiceImage, String, QQueryOperations> relativePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relativePath');
    });
  }
}
