/// Query to get collection by id
const String getVideoUrlById = r'''
query getVideoUrlById($id: ID!) {
 node(id : $id) {
   ... on Video {
    id
    sources {
    url
    }
    previewImage {
      url
    }
  }
 }
}
''';
