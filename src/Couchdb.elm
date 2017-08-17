module Couchdb exposing (Config, Row, defineDb, fetch, specialView, view, store)

{-|
@docs Config, Row, defineDb, fetch, specialView, view, store
-}

import Http
import Json.Decode as Decode
import Json.Encode as Encode

import Couchdb.Internal exposing (..)
import Couchdb.View as View


{-|-}
type alias Config = Couchdb.Internal.Config
{-|-}
type alias Row key value = Couchdb.Internal.Row key value
{-|-}
defineDb : String -> String -> Config
defineDb = Couchdb.Internal.defineDb


{-|-}
fetch :
  Decode.Decoder a
  -> Config
  -> String
  -> Http.Request a
fetch decoder config key =
  let
    fetchAddr =
      makePath [configString config, key]
  in
    Http.get fetchAddr decoder


{-|-}
specialView :
  Decode.Decoder key
  -> Decode.Decoder value
  -> Config
  -> String
  -> Http.Request (List (Row key value))
specialView =
  View.specialViewWith View.settings


{-|-}
view :
  Decode.Decoder key
  -> Decode.Decoder value
  -> Config
  -> String
  -> String
  -> Http.Request (List (Row key value))
view =
  View.viewWith View.settings


{-|-}
store :
  (a -> Encode.Value)
  -> Config
  -> String
  -> a
  -> Http.Request String
store encode config key value =
  let
    postAddr =
      configString config ++ "/" ++ key
    body = Http.jsonBody (encode value)
  in
    Http.post postAddr body Decode.string
