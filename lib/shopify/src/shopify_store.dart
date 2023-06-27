import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shopify_flutter/enums/enums.dart';
import 'package:shopify_flutter/enums/src/sort_key_collection.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_all_collections_optimized.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_all_products_from_collection_by_id.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_all_products_on_query.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_collections_by_ids.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_metafileds_from_product.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_product_recommendations.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_products_by_ids.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_shop.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_collections_and_n_products_sorted.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_products_after_cursor.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_products_after_cursor_within_collection.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_products_on_query_after_cursor.dart';
import 'package:shopify_flutter/mixins/src/shopfiy_error.dart';
import 'package:shopify_flutter/models/src/collection/collections/collections.dart';
import 'package:shopify_flutter/models/src/product/metafield/metafield.dart';
import 'package:shopify_flutter/models/src/product/product.dart';
import 'package:shopify_flutter/models/src/product/products/products.dart';
import 'package:shopify_flutter/models/src/shop/shop.dart';

import '../../graphql_operations/storefront/queries/get_featured_collections.dart';
import '../../graphql_operations/storefront/queries/get_n_products.dart';
import '../../graphql_operations/storefront/queries/get_products.dart';
import '../../models/src/collection/collection.dart';
import '../../shopify_config.dart';

/// ShopifyStore provides various methods related to the shopify store.
class ShopifyStore with ShopifyError {
  ShopifyStore._();

  static final ShopifyStore instance = ShopifyStore._();

  GraphQLClient? get _graphQLClient => ShopifyConfig.graphQLClient;

  /// Returns a List of [Product].
  ///
  /// Simply returns all Products from your Store.
  Future<List<Product>> getAllProducts(
      {String? metafieldsNamespace,
      FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
      String? langCode,
      String? countryCode}) async {
    List<Product> productList = [];
    Products tempProduct;
    String? cursor;
    WatchQueryOptions _options;
    do {
      var variables = <String, dynamic>{
        'cursor': cursor,
        'metafieldsNamespace': metafieldsNamespace,
      };
      if (langCode != null) {
        variables['langCode'] = 'EN';
      }
      if (countryCode != null) {
        variables['countryCode'] = 'IN';
      }
      _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getProductsQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      tempProduct =
          (Products.fromGraphJson((result.data ?? const {})["products"] ?? {}));

      productList += tempProduct.productList;
      cursor = productList.isNotEmpty ? productList.last.cursor : '';
    } while ((tempProduct.hasNextPage == true));
    return productList;
  }

  /// Returns a List of [Product].
  ///
  /// Returns the first [limit] Products after the given [startCursor].
  /// [limit] has to be in the range of 0 and 250.
  Future<List<Product>> getXProductsAfterCursor(int limit, String startCursor,
      {bool reverse = false,
      SortKeyProduct sortKeyProduct = SortKeyProduct.TITLE,
      FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
      String? langCode,
      String? countryCode}) async {
    List<Product> productList = [];
    Products tempProduct;
    String cursor = startCursor;
    var variables = <String, dynamic>{
      'x': limit,
      'cursor': cursor,
      'reverse': reverse,
      'sortKey': sortKeyProduct.parseToString()
    };
    if (langCode != null) {
      variables['langCode'] = 'EN';
    }
    if (countryCode != null) {
      variables['countryCode'] = 'IN';
    }
    final WatchQueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getXProductsAfterCursorQuery),
        variables: variables);
    final QueryResult result = await _graphQLClient!.query(_options);
    checkForError(result);
    tempProduct =
        (Products.fromGraphJson((result.data ?? const {})["products"] ?? {}));
    productList += tempProduct.productList;
    return productList;
  }

  /// Returns a List of [Product].
  ///
  /// Returns the Products associated to the given id's in [idList]
  Future<List<Product>?> getProductsByIds(List<String> idList,
      {String? langCode,
      String? countryCode,
      FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork}) async {
    List<Product>? productList = [];

    Map<String, dynamic> variables = <String, dynamic>{
      'ids': idList,
    };
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }

    final QueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getProductsByIdsQuery),
        variables: variables);
    final QueryResult result = await _graphQLClient!.query(_options);
    checkForError(result);
    var response = result.data!;
    var newResponse = {
      'edges': List.generate(response['nodes'].length,
          (index) => {'node': response['nodes'][index]})
    };
    productList = Products.fromGraphJson(newResponse).productList;
    return productList;
  }

  /// Returns [n] Products.
  ///
  /// Returns the first [n] sorted by the [sortKey].
  /// [reverse] reverses the returned products if set on true.
  /// [SortKey] is an enum, example use cases:
  ///
  ///  SortKey.TITLE,
  ///  SortKey.PRODUCT_TYPE,
  ///  SortKey.VENDOR,
  ///  SortKey.UPDATED_AT,
  ///  SortKey.CREATED_AT,
  ///  SortKey.BEST_SELLING,
  ///  SortKey.PRICE,
  ///  SortKey.ID,
  ///  SortKey.RELEVANCE,
  Future<List<Product>?> getNProducts(int n,
      {bool? reverse,
      SortKeyProduct sortKey = SortKeyProduct.PRODUCT_TYPE,
      FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
      String? langCode,
      String? countryCode}) async {
    List<Product>? productList = [];
    Map<String, dynamic> variables = <String, dynamic>{
      'n': n,
      'sortKey': sortKey.parseToString(),
      'reverse': reverse,
    };
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }
    final WatchQueryOptions _options = WatchQueryOptions(
      fetchPolicy: fetchPolicy,
      document: gql(getNProductsQuery),
      variables: variables,
    );
    final QueryResult result = await _graphQLClient!.query(_options);
    checkForError(result);
    productList =
        (Products.fromGraphJson((result.data ?? const {})["products"] ?? {}))
            .productList;
    return productList;
  }

  /// Returns a list of recommended [Product] by given id.
  Future<List<Product>?> getProductRecommendations(
    String productId, {
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    try {
      Map<String, dynamic> variables = <String, dynamic>{'id': productId};
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      final WatchQueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getProductRecommendationsQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      var newResponse = List.generate(
          result.data!['productRecommendations']?.length ?? 0,
          (index) => {
                "node":
                    (result.data!['productRecommendations'] ?? const {})[index]
              });
      var tempProducts = {"edges": newResponse};
      return Products.fromGraphJson(tempProducts).productList;
    } catch (e) {
      log(e.toString());
    }
    return [Product.fromGraphJson({})];
  }

  /// Returns a List of [Collection]
  Future<List<Collection>?> getCollectionsByIds(
    List<String> idList, {
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    try {
      Map<String, dynamic> variables = <String, dynamic>{
        'ids': idList,
      };
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      final WatchQueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getCollectionsByIdsQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      var newResponse = List.generate(result.data!['nodes']?.length ?? 0,
          (index) => {"node": (result.data!['nodes'] ?? const {})[index]});
      var tempCollection = {"edges": newResponse};
      return Collections.fromGraphJson(tempCollection).collectionList;
    } catch (e) {
      log(e.toString());
    }
    return [Collection.fromJson({})];
  }

  /// Returns the Shop.
  Future<Shop> getShop(
      {FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork}) async {
    final WatchQueryOptions _options = WatchQueryOptions(
      fetchPolicy: fetchPolicy,
      document: gql(getShopQuery),
    );
    final QueryResult result = await _graphQLClient!.query(_options);
    checkForError(result);
    return Shop.fromJson(result.data!['shop']);
  }

  /// Returns a collection by handle.
  @Deprecated('Use [getCollectionById]')
  Future<Collection> getCollectionByHandle(
    String collectionName, {
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    try {
      Map<String, dynamic> variables = <String, dynamic>{
        'query': collectionName
      };
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      final WatchQueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getFeaturedCollectionQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      return Collections.fromGraphJson(result.data!['collections'])
          .collectionList[0];
    } catch (e) {
      log(e.toString());
    }
    return Collection.fromGraphJson({});
  }

  /// Returns a collection by id.
  Future<Collection?> getCollectionById(
    String collectionId, {
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    try {
      Map<String, dynamic> variables = <String, dynamic>{
        'ids': [collectionId],
      };
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      final WatchQueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getCollectionsByIdsQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      return Collection.fromGraphJson(result.data!);
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  /// Returns all available collections.
  ///
  /// Tip: When editing Collections you can choose on which channel or app you want to make them available.
  Future<List<Collection>> getAllCollections(
      {SortKeyCollection sortKeyCollection = SortKeyCollection.UPDATED_AT,
      bool reverse = false,
      String? langCode,
      String? countryCode,
      FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork}) async {
    List<Collection> collectionList = [];
    Collections tempCollection;
    String? cursor;
    WatchQueryOptions _options;
    do {
      Map<String, dynamic> variables = <String, dynamic>{
        'cursor': cursor,
        'sortKey': sortKeyCollection.parseToString(),
        'reverse': reverse,
      };
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getAllCollectionsOptimizedQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      tempCollection = (Collections.fromGraphJson(
          (result.data ?? const {})['collections'] ?? {}));
      collectionList = tempCollection.collectionList + collectionList;
      cursor = collectionList.isNotEmpty ? collectionList.last.cursor : '';
    } while ((tempCollection.hasNextPage == true));
    return collectionList;
  }

  /// Returns N products from each X collections.
  ///
  /// Tip: When editing Collections you can choose on which channel or app you want to make them available.
  Future<List<Collection>?> getXCollectionsAndNProductsSorted(
    int n,
    int x, {
    SortKeyProductCollection sortKeyProductCollection =
        SortKeyProductCollection.CREATED,
    SortKeyCollection sortKeyCollection = SortKeyCollection.UPDATED_AT,
    bool reverse = false,
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    List<Collection>? collectionList;
    String? cursor;
    WatchQueryOptions _options;
    Map<String, dynamic> variables = <String, dynamic>{
      'cursor': cursor,
      'sortKey': sortKeyCollection.parseToString(),
      'reverse': reverse,
      'sortKeyProduct': sortKeyProductCollection.parseToString(),
      'x': x,
      'n': n
    };
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }
    _options = WatchQueryOptions(
      fetchPolicy: fetchPolicy,
      document: gql(getXCollectionsAndNProductsSortedQuery),
      variables: variables,
    );
    final QueryResult result = await _graphQLClient!.query(_options);
    checkForError(result);
    collectionList = (Collections.fromGraphJson(
            (result.data ?? const {})['collections'] ?? {}))
        .collectionList;
    return collectionList;
  }

  /// Returns a List of [Product].
  ///
  /// Returns all Products from the [Collection] with the [id].
  Future<List<Product>> getAllProductsFromCollectionById(
    String id, {
    SortKeyProductCollection sortKeyProductCollection =
        SortKeyProductCollection.CREATED,
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    String? cursor;
    List<Product> productList = [];
    Collection collection;
    QueryOptions _options;
    do {
      Map<String, dynamic> variables = <String, dynamic>{
        'id': id,
        'cursor': cursor,
        'sortKey': sortKeyProductCollection.parseToString()
      };
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getAllProductsFromCollectionByIdQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      productList
          .addAll(Collection.fromGraphJson(result.data!).products.productList);
      collection = (Collection.fromGraphJson(result.data!));
      cursor = productList.isNotEmpty ? productList.last.cursor : '';
    } while (collection.products.hasNextPage == true);
    return productList;
  }

  /// Returns a List of [Product].
  ///
  /// Returns the first [limit] Products after the given [startCursor].
  /// [limit] has to be in the range of 0 and 250.
  Future<List<Product>?> getXProductsAfterCursorWithinCollection(
    String id,
    int limit, {
    String? startCursor,
    SortKeyProductCollection sortKey = SortKeyProductCollection.BEST_SELLING,
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    bool reverse = false,
    String? langCode,
    String? countryCode,
  }) async {
    String? cursor = startCursor;
    Map<String, dynamic> variables = <String, dynamic>{
      'id': id,
      'cursor': cursor,
      'limit': limit,
      'sortKey': sortKey.parseToString(),
      'reverse': reverse,
    };
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }
    final WatchQueryOptions _options = WatchQueryOptions(
      fetchPolicy: fetchPolicy,
      document: gql(getXProductsAfterCursorWithinCollectionQuery),
      variables: variables,
    );
    final QueryResult result = await _graphQLClient!.query(_options);
    checkForError(result);
    return (Collection.fromGraphJson(result.data!)).products.productList;
  }

  /// Returns a List of [Product].
  ///
  /// Gets all [Product] from a [query] search sorted by [sortKey].
  Future<List<Product>> getAllProductsOnQuery(
    String cursor,
    String query, {
    SortKeyProduct? sortKey,
    bool reverse = false,
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    String? cursor;
    List<Product> productList = [];
    Products products;
    WatchQueryOptions _options;
    do {
      Map<String, dynamic> variables = <String, dynamic>{
        'cursor': cursor,
        'sortKey': sortKey?.parseToString(),
        'query': query,
        'reverse': reverse
      };
      if (langCode != null) {
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
      }
      _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getAllProductsOnQueryQuery),
        variables: variables,
      );
      final QueryResult result = await _graphQLClient!.query(_options);
      checkForError(result);
      productList.addAll(
          (Products.fromGraphJson((result.data!)['products'])).productList);
      products =
          (Products.fromGraphJson((result.data ?? const {})['products']));
      cursor = productList.isNotEmpty ? productList.last.cursor : '';
    } while (products.hasNextPage == true);
    return productList;
  }

  /// Returns a List of [Product].
  ///
  /// Gets [limit] amount of [Product] from the [query] search, sorted by [sortKey].
  Future<List<Product>?> getXProductsOnQueryAfterCursor(
    String query,
    int limit,
    String? cursor, {
    SortKeyProduct? sortKey,
    bool reverse = false,
    FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
    String? langCode,
    String? countryCode,
  }) async {
    Map<String, dynamic> variables = <String, dynamic>{
      if (cursor != null) 'cursor': cursor,
      'limit': limit,
      'sortKey': sortKey?.parseToString(),
      'query': query,
      'reverse': reverse,
    };
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }
    final WatchQueryOptions _options = WatchQueryOptions(
      fetchPolicy: fetchPolicy,
      document: gql(getXProductsOnQueryAfterCursorQuery),
      variables: variables,
    );
    final QueryResult result =
        await ShopifyConfig.graphQLClient!.query(_options);
    checkForError(result);
    return Products.fromGraphJson((result.data ?? const {})['products'])
        .productList;
  }

  /// Returns a List of [Metafield].
  ///
  /// Gets [Metafield]s of [Product] optionally filtered by namespace.
  Future<List<Metafield>> getMetafieldsFromProduct(
      String productHandle, String namespace,
      {FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork}) async {
    final WatchQueryOptions _options = WatchQueryOptions(
        fetchPolicy: fetchPolicy,
        document: gql(getMetafieldsFromProductQuery),
        variables: {'handle': productHandle, 'namespace': namespace});
    final QueryResult result =
        await ShopifyConfig.graphQLClient!.query(_options);
    checkForError(result);
    return (result.data!['productByHandle']['metafields']['edges']
            as List<Object>)
        .map((e) => Metafield.fromGraphJson(e as Map<String, dynamic>))
        .toList();
  }
}
