// This is the starting point of the app
// Everything that appears on the screen or affects appearance on the screen is a widget

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'code/routes.dart';

// use system chrome to control orientation(set to portrait)
void main() => runApp(MyApp());

var baseUrl = 'http://192.168.10.51:5000';
//var baseUrl = 'http://192.168.100.12:5000';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For GraphQL client, initialize with endpoint, cache
    // and API token if endpoint require authentication
    // this initialisation should happen within the build of the app

    // HttpLink is where we set the GraphQL backend url and API key & other headers, if any
    final HttpLink httpLink =
        HttpLink(uri: baseUrl + '/classlist_api/', headers: <String, String>{
      //
    });

    // AuthLink is where we set the authentication token, if any
    final AuthLink authLink = AuthLink(
        // getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
        // OR
        // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
        );

    final Link link = authLink.concat(httpLink);

    // This is where we create a GraphQL client instance using the previous HttpLink
    // and a selected cache
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        // To enable apollo-like normalization, use a NormalizedInMemoryCache or OptimisticCache:
        cache: NormalizedInMemoryCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
      ),
    );

    // To use initialised client, app needs to be wrapped with GraphQLProvider widget
    // or GraphQLConsumer that has a builder and enables you to use client directly
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MaterialApp(
          color: Colors.white,
          title: 'Class Attendance System',
          routes: routes,
          theme: ThemeData(primarySwatch: Colors.blueGrey),
        ),
      ),
    );
  }
}
