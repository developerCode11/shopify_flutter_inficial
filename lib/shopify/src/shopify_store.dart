import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shopify_flutter/enums/enums.dart';
import 'package:shopify_flutter/enums/src/sort_key_collection.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/cart_line_add.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/cart_lines_update.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/create_cart.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/product_create_media.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/remove_line_items_from_cart.dart';
import 'package:shopify_flutter/graphql_operations/storefront/mutations/staged_upload_create.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_all_collections_optimized.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_all_products_from_collection_by_id.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_all_products_on_query.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_cart_by_id.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_collections_by_ids.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_product_recommendations.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_products_by_ids.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_shop.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_collections_and_n_products_sorted.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_products_after_cursor.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_products_after_cursor_within_collection.dart';
import 'package:shopify_flutter/graphql_operations/storefront/queries/get_x_products_on_query_after_cursor.dart';
import 'package:shopify_flutter/mixins/src/shopfiy_error.dart';
import 'package:shopify_flutter/models/src/cart/cart_input_model.dart';
import 'package:shopify_flutter/models/src/cart/cart_model.dart' as cart;
import 'package:shopify_flutter/models/src/collection/collections/collections.dart';
import 'package:shopify_flutter/models/src/product/metafield/metafield.dart';
import 'package:shopify_flutter/models/src/product/product.dart';
import 'package:shopify_flutter/models/src/product/products/products.dart';
import 'package:shopify_flutter/models/src/product/reviews/review_list_model.dart';
import 'package:shopify_flutter/models/src/product/stage_uploads/media.dart';
import 'package:shopify_flutter/models/src/product/stage_uploads/stage_upload.dart';
import 'package:shopify_flutter/models/src/product/stage_uploads/stage_uploads_input.dart';
import 'package:shopify_flutter/models/src/shop/shop.dart';
import 'package:shopify_flutter/shopify/shopify.dart';

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
  GraphQLClient? get _graphQLClientAdmin => ShopifyConfig.graphQLClientAdmin;

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
        variables['langCode'] = langCode;
      }
      if (countryCode != null) {
        variables['countryCode'] = countryCode;
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
  Future<List<Metafield>> getMetaFieldsFromProduct(String productId) async {
    List<Metafield> metafields = [];
    try {
      http.Response response = await http.get(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/products/$productId/metafields.json"),
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        metafields = (data['metafields'] as List)
            .map((e) => Metafield.fromGraphJson(e))
            .toList();
      }
    } catch (e) {
      return [];
    }
    return metafields;
  }

  /// Returns a specific [Metafield] from [productId] and [metaFieldId].
  ///
  Future<Metafield?> getMetaFieldsFromMetaField(
      String productId, String metaFieldId) async {
    try {
      http.Response response = await http.get(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/products/$productId/metafields/$metaFieldId.json"),
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Metafield.fromGraphJson(data['metafield']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Metafield?> createMetaFieldForProduct(String productId,
      String namespace, String key, String value, String type) async {
    try {
      http.Response response = await http.post(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/products/$productId/metafields.json"),
        body: {
          "metafield": {
            "namespace": namespace,
            "key": key,
            "value": value,
            "type": type
          }
        },
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Metafield.fromGraphJson(data['metafield']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Metafield?> updateMetaFieldsFromMetaField(
      String productId,
      String metaFieldId,
      String namespace,
      String key,
      String value,
      String type) async {
    try {
      http.Response response = await http.put(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/products/$productId/metafields/$metaFieldId.json"),
        body: {
          "metafield": {
            "namespace": namespace,
            "key": key,
            "value": value,
            "type": type
          }
        },
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Metafield.fromGraphJson(data['metafield']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> deleteMetaFieldsFromMetaField(
      String productId, String metaFieldId) async {
    try {
      http.Response response = await http.delete(
        Uri.parse(
            "${ShopifyConfig.storeUrl}/admin/api/${ShopifyConfig.apiVersion}/products/$productId/metafields/$metaFieldId.json"),
        headers: {
          'X-Shopify-Access-Token': ShopifyConfig.adminAccessToken,
        },
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<StagedUpload> stagedUploadCreate({
    required InputList input,
    required String productId,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(stagedUploadsCreate),
      variables: input.toJson(),
    );
    final QueryResult result = await _graphQLClientAdmin!.mutate(_options);
    checkForError(
      result,
      key: 'stagedUploadsCreate',
      errorKey: 'userErrors',
    );
    StagedUpload stagedUpload = StagedUpload.fromJson(result.data ?? {});
    await Future.forEach(
        stagedUpload.stagedUploadsCreate?.stagedTargets ?? <StagedTargets>[],
        (StagedTargets stagedTarget) async {
      int index = stagedUpload.stagedUploadsCreate?.stagedTargets
              ?.indexWhere((element) => element.url == stagedTarget.url) ??
          -1;
      await uploadMediaToTheShopifyStore(
          stagedTargets: stagedTarget,
          file: File(input.input?[index].filepath ?? ''));
    });
    // List<Media> medias = [];
    // for (int i = 0;
    //     i < (stagedUpload.stagedUploadsCreate?.stagedTargets?.length ?? 0);
    //     i++) {
    //   uploadMediaToTheShopifyStore(
    //       stagedTargets: stagedUpload.stagedUploadsCreate?.stagedTargets?[i],
    //       file: File(input.input?[i].filepath ?? ''));

    // medias.add(Media(
    //   originalSource:
    //       stagedUpload.stagedUploadsCreate?.stagedTargets?[i].resourceUrl,
    //   alt: input.input?[i].resource,
    //   mediaContentType: input.input?[i].resource,
    // ));
    // }
    // await Future.delayed(const Duration(milliseconds: 200));
    // await assignMediaToTheProduct(input: medias, productId: productId);
    return stagedUpload;
  }

  Future<void> assignMediaToTheProduct({
    required List<Media> input,
    required String productId,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(productCreateMedia),
      variables: {
        'media': input.map((e) => e.toJson()).toList(),
        'productId': productId,
      },
    );
    final QueryResult result = await _graphQLClientAdmin!.mutate(_options);
    checkForError(
      result,
      key: 'productCreateMedia',
      errorKey: 'mediaUserErrors',
    );
  }

  Future<void> uploadMediaToTheShopifyStore(
      {required StagedTargets? stagedTargets, required File file}) async {
    Map<String, String> params = {};
    stagedTargets?.parameters?.forEach((element) {
      params['${element.name}'] = element.value.toString();
    });
    final multipartFile = http.MultipartFile.fromBytes(
        'file', file.readAsBytesSync(),
        filename: file.path.split('/').last);
    final request =
        http.MultipartRequest('POST', Uri.parse('${stagedTargets?.url}'))
          ..files.add(multipartFile);
    request.fields.addAll(params);
    final responseStream = await request.send();
    final response = await http.Response.fromStream(responseStream);
  }

  Future<ReviewListModel> getProductReview(
      {required String apiToken, required String productId}) async {
    try {
      http.Response response1 = await http.get(
        Uri.parse(
            "https://judge.me/api/v1/products/-1?external_id=$productId&shop_domain=${ShopifyConfig.storeUrl?.replaceAll('https://', '')}&api_token=$apiToken"),
      );
      if (response1.statusCode == 200) {
        final data = jsonDecode(response1.body);
        http.Response response = await http.get(
          Uri.parse(
              "https://judge.me/api/v1/reviews?shop_domain=${ShopifyConfig.storeUrl?.replaceAll('https://', '')}&api_token=$apiToken&product_id=${data['product']['id']}&published=true&current_page=1&per_page=100"),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return ReviewListModel.fromJson(data);
        }
      }
    } catch (e) {
      return ReviewListModel(reviews: []);
    }
    return ReviewListModel(reviews: []);
  }

  Future<bool> createProductReview({
    required String apiToken,
    required String productId,
    required List<String> images,
    required String reviewBody,
    required String email,
    required String name,
    required String rating,
  }) async {
    final body = {
      "shop_domain": ShopifyConfig.storeUrl?.replaceAll('https://', ''),
      "platform": "shopify",
      "id": productId,
      "email": email,
      "name": name,
      "rating": rating,
      "body": reviewBody,
      "picture_urls": images
    };
    http.Response response = await http.post(
      Uri.parse(
        "https://judge.me/api/v1/reviews?shop_domain=${ShopifyConfig.storeUrl?.replaceAll('https://', '')}&api_token=$apiToken",
      ),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getCountOfReview({
    required String apiToken,
    required String productId,
  }) async {
    Map<String, dynamic> countData = {};
    List ratings = [1, 2, 3, 4, 5];

    http.Response response1 = await http.get(
      Uri.parse(
          "https://judge.me/api/v1/products/-1?external_id=$productId&shop_domain=${ShopifyConfig.storeUrl?.replaceAll('https://', '')}&api_token=$apiToken"),
    );
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      await Future.forEach(ratings, (element) async {
        countData["$element"] = await getCountOfRating(
          apiToken: apiToken,
          productId: data['product']['id'].toString(),
          rating: element,
        );
      });
      return countData;
    }
    return {};
  }

  Future<String> getCountOfRating({
    required String apiToken,
    required String productId,
    required int rating,
  }) async {
    http.Response response = await http.get(
      Uri.parse(
          "https://judge.me/api/v1/reviews/count?&shop_domain=${ShopifyConfig.storeUrl?.replaceAll('https://', '')}&api_token=$apiToken&product_id=$productId&rating=$rating&published=true"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'].toString();
    }

    return '0';
  }

  Future<bool> deleteReview({
    required String apiToken,
    required String reviewId,
  }) async {
    http.Response response = await http.put(
      Uri.parse(
          "https://judge.me/api/v1/reviews/$reviewId?shop_domain=${ShopifyConfig.storeUrl?.replaceAll('https://', '')}&api_token=$apiToken"),
      body: {
        "curated": "spam",
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<cart.Cart> createCart({
    required CartInput input,
    required String customerId,
    String? langCode,
    String? countryCode,
  }) async {
    Map<String, dynamic> variables = input.toJson();
    if (langCode != null) {
      variables['langCode'] = langCode;
    }
    if (countryCode != null) {
      variables['countryCode'] = countryCode;
    }

    final MutationOptions _options = MutationOptions(
      document: gql(cartCreate),
      variables: variables,
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'cartCreate',
      errorKey: 'userErrors',
    );
    ShopifyCustomer _shopifyCustomer = ShopifyCustomer.instance;
    cart.Cart cartModel =
        cart.Cart.fromJson(result.data?['cartCreate']['cart'] ?? {});
    await _shopifyCustomer.createMetaFieldForCustomer(
      customerId: customerId.split('/').last,
      namespace: 'cart',
      key: 'cartId',
      value: cartModel.id,
      type: 'string',
    );
    return cartModel;
  }

  Future<cart.Cart> addLineItemsToCart({
    required List<Lines> lines,
    required String cartId,
    String? langCode,
    String? countryCode,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(cartLinesAdd),
      variables: {
        'cartId': cartId,
        'lines': lines.map((e) => e.toJson()).toList(),
        if (langCode != null) 'langCode': langCode,
        if (countryCode != null) 'countryCode': countryCode,
      },
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'cartLinesAdd',
      errorKey: 'userErrors',
    );
    cart.Cart cartModel =
        cart.Cart.fromJson(result.data?['cartLinesAdd']['cart'] ?? {});
    return cartModel;
  }

  Future<cart.Cart> removeLineItemsFromCart({
    required List<String> lineIds,
    required String cartId,
    required String customerId,
    String? langCode,
    String? countryCode,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(cartLinesRemove),
      variables: {
        'cartId': cartId,
        'lineIds': lineIds.map((e) => e.toString()).toList(),
        if (langCode != null) 'langCode': langCode,
        if (countryCode != null) 'countryCode': countryCode,
      },
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'cartLinesRemove',
      errorKey: 'userErrors',
    );
    cart.Cart cartModel =
        cart.Cart.fromJson(result.data?['cartLinesRemove']['cart'] ?? {});
    ShopifyCustomer _shopifyCustomer = ShopifyCustomer.instance;
    if (cartModel.lines?.edges?.isEmpty ?? true) {
      final List<Metafield> metafields = await _shopifyCustomer
          .getMetaFieldsFromCustomer(customerId.split('/').last);
      List<Metafield> temp = metafields
          .where((element) =>
              element.key == 'cartId' && element.namespace == 'cart')
          .toList();
      if (temp.isNotEmpty) {
        await _shopifyCustomer.removeMetaField(
          customerID: customerId.split('/').last,
          metaFieldId: temp.first.id,
        );
      }
    }
    return cartModel;
  }

  Future<cart.Cart> updateLineItemsOfCart({
    required List<Lines> lines,
    required String cartId,
    String? langCode,
    String? countryCode,
  }) async {
    final MutationOptions _options = MutationOptions(
      document: gql(cartLinesUpdate),
      variables: {
        'cartId': cartId,
        'lines': lines.map((e) => e.toJson()).toList(),
        if (langCode != null) 'langCode': langCode,
        if (countryCode != null) 'countryCode': countryCode,
      },
    );
    final QueryResult result = await _graphQLClient!.mutate(_options);
    checkForError(
      result,
      key: 'cartLinesUpdate',
      errorKey: 'userErrors',
    );
    cart.Cart cartModel =
        cart.Cart.fromJson(result.data?['cartLinesUpdate']['cart'] ?? {});
    return cartModel;
  }

  Future<cart.Cart?> getCustomerCart(
      {required String customerId,
      FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork,
      String? langCode,
      String? countryCode}) async {
    ShopifyCustomer _shopifyCustomer = ShopifyCustomer.instance;
    final List<Metafield> metafields = await _shopifyCustomer
        .getMetaFieldsFromCustomer(customerId.split('/').last);
    if (metafields.isNotEmpty) {
      List<Metafield> temp = metafields
          .where((element) =>
              element.key == 'cartId' && element.namespace == 'cart')
          .toList();
      if (temp.isNotEmpty) {
        final WatchQueryOptions _options = WatchQueryOptions(
          fetchPolicy: fetchPolicy,
          document: gql(getCartById),
          variables: {
            'cartId': temp.first.value,
            if (langCode != null) 'langCode': langCode,
            if (countryCode != null) 'countryCode': countryCode,
          },
        );
        final QueryResult result =
            await ShopifyConfig.graphQLClient!.query(_options);
        checkForError(
          result,
        );
        cart.Cart cartModel = cart.Cart.fromJson(result.data?['cart'] ?? {});
        return cartModel;
      }
    }
    return null;
  }
}
