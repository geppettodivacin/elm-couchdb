module Couchdb exposing (Config, fetch, store)

import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Config =
    { host : String
    , db : String
    }


fetch :
  Decode.Decoder a
  -> Config
  -> String
  -> Http.Request a
fetch decoder config key =
  let
    fetchAddr =
      configString config ++ "/" ++ key
  in
    Http.get fetchAddr decoder


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


configString : Config -> String
configString config =
  "http://" ++ config.host ++ "/" ++ config.db
