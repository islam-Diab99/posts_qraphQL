import 'package:dartz/dartz.dart';
import 'package:graphql/client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getAllPosts();
  Future<Unit> deletePost(int postId);
  Future<Unit> updatePost(PostModel postModel);
  Future<Unit> addPost(PostModel postModel);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final GraphQLClient client;

  PostRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PostModel>> getAllPosts() async {

    const String query = '''
    query (\$options: PageQueryOptions) {
      posts(options: \$options) {
        data {
          id
          title
          body
        }
      }
    }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
         fetchPolicy: FetchPolicy.cacheAndNetwork,
      variables: {
        "options": {"paginate": {"page": 1, "limit": 10}}
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw RemoteServerException();
    }

    final List data = result.data?['posts']['data'];
    print(result.data?['posts']['data']);
    final List<PostModel> posts = data.map((json) => PostModel.fromJson(json)).toList();

    return posts;
  }

  @override
  Future<Unit> addPost(PostModel postModel) async {
    const String mutation = '''
    mutation (\$input: CreatePostInput!) {
      createPost(input: \$input) {
        title
        body
      }
    }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        "input": {
          "title": postModel.title,
          "body": postModel.body,
        }
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw RemoteServerException();
    }

    return Future.value(unit);
  }

  @override
  Future<Unit> deletePost(int postId) async {
    const String mutation = '''
    mutation (\$id: ID!) {
      deletePost(id: \$id)
    }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {"id": postId.toString()},
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw RemoteServerException();
    }

    return Future.value(unit);
  }

  @override
  Future<Unit> updatePost(PostModel postModel) async {
    const String mutation = '''
    mutation (\$id: ID!, \$input: UpdatePostInput!) {
      updatePost(id: \$id, input: \$input) {
        id
        title
        body
      }
    }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
   
      variables: {
        "id": postModel.id.toString(),
        "input": {
          "title": postModel.title,
          "body": postModel.body,
        }
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw RemoteServerException();
    }

    return Future.value(unit);
  }
}
