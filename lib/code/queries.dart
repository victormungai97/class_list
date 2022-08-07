// here, all queries will reside
// a query is the GraphQL equivalent of HTTP GET
// '\\' escapes the '$'
/// Creating queries involves wrapping query in a multiline string

/// Here, we shall get the number of images required for registration

String numOfImages = """
query ImagesNumberQuery{
  numberImages
}
"""
    .replaceAll('\n', ' ');

/// Get all the departments that are registered

String allDepartments = """
query AllDepartmentsQuery{
  allDepartments {
    edges {
      node {
        name
      }
    }
  }
}
"""
    .replaceAll('\n', " ");
