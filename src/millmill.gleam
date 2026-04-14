import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/uri.{type Uri}
import lustre
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import modem

// MAIN -------------------------------------------
pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MODEL ------------------------------------------
type Model {
  Model(posts: Dict(Int, Post), route: Route)
}

type Post {
  Post(id: Int, title: String, summary: String, text: String)
}

/// Copied from Lustre example docs about routing.
/// In a real application, we'll likely want to show different views depending on
/// which URL we are on:
///
/// - /      - show the home page
/// - /posts - show a list of posts
/// - /about - show an about page
/// - ...
///
/// We could store the `Uri` or perhaps the path as a `String` in our model, but
/// this can be awkward to work with and error prone as our application grows.
///
/// Instead, we _parse_ the URL into a nice Gleam custom type with just the
/// variants we need! This lets us benefit from Gleam's pattern matching,
/// exhaustiveness checks, and LSP features, while also serving as documentation
/// for our app: if you can get to a page, it must be in this type!
///
type Route {
  Index
  Posts
  PostById(id: Int)
  Experience
  /// It's good practice to store whatever `Uri` we failed to match in case we
  /// want to log it or hint to the user that maybe they made a typo.
  NotFound(uri: Uri)
}

fn parse_route(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    [] | [""] -> Index

    ["posts"] -> Posts

    ["post", post_id] -> 
      case int.parse(post_id) {
        Ok(post_id) -> PostById(id: post_id)
        Error(_) -> NotFound(uri:)
      }

    ["experience"] -> Experience

    _ -> NotFound(uri:)
  }
}

