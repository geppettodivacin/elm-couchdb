module Couchdb exposing (Database, Row, defineDb, fetch, specialView, view, store)

{-| The primary functions used to access CouchDB.

# Database
@docs Database, defineDb

# Simple requests
@docs fetch, specialView, view, store

# Views
@docs Row, view, specialView
-}

import Http
import Json.Decode as Decode
import Json.Encode as Encode

import Couchdb.Internal exposing (..)
import Couchdb.View as View


{-| Represents a single database with an address and a database name.
-}
type alias Database = Couchdb.Internal.Database


{-| Create a database reference. Note that no communication needs to
take place as the CouchDB protocol is RESTful. Users are not supported
at this time.

    defineDb "localhost:5984" "exampledb" : Database
-}
defineDb : String -> String -> Database
defineDb address dbname =
  Couchdb.Internal.Database address dbname


{-| Create a fetch request for a particular document. You must provide 
the decoder for the document and the document id.

    fetch (Json.Decode.field "value" Json.Decode.string) database docId : Request String
-}
fetch :
  Decode.Decoder a
  -> Database
  -> String
  -> Http.Request a
fetch decoder db key =
  let
    fetchAddr =
      makePath [databaseString db, key]
  in
    Http.get fetchAddr decoder


{-| Row in a view. Contains `.id`, `.key`, and `.value`.
-}
type alias Row key value = View.Row key value


{-| Create a request for a view in a design document. In order to
extract the rows from the response, you must provide a JSON decoder for
the key and for the value. For more view options, see `Couchdb.View`.

    view keyDecoder valueDecoder database designName viewName : Request a
-}
view :
  Decode.Decoder key
  -> Decode.Decoder value
  -> Database
  -> String
  -> String
  -> Http.Request (List (Row key value))
view =
  View.viewWith View.initOptions


{-| Create a request for a view at a particular path as opposed to
within a specific design document. For more view options, see
`Couchdb.View`.

    specialView (Json.Decode.string) docDecoder database "_all_docs" : Request a
-}
specialView :
  Decode.Decoder key
  -> Decode.Decoder value
  -> Database
  -> String
  -> Http.Request (List (Row key value))
specialView =
  View.specialViewWith View.initOptions


{-| Create a request to store a document. Note that you are responsible
for including the revision with your document if this is updating an
already-existing document.
-}
store :
  (a -> Encode.Value)
  -> Database
  -> String
  -> a
  -> Http.Request String
store encode db key value =
  let
    postAddr =
      databaseString db ++ "/" ++ key
    body = Http.jsonBody (encode value)
  in
    Http.post postAddr body Decode.string
