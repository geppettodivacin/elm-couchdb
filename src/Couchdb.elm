module Couchdb exposing (Config, Row, fetch, specialView, view, store)

import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Config =
    { host : String
    , db : String
    }


makePath : List String -> String
makePath parts =
  String.concat (List.intersperse "/" parts)


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


type alias Row key value = 
    { id : String
    , key : key
    , value : value
    }


specialView :
  Decode.Decoder key
  -> Decode.Decoder value
  -> Config
  -> String
  -> Http.Request (List (Row key value))
specialView keyDecoder valueDecoder config viewPath =
  let
    fetchAddr =
      makePath [configString config, viewPath]

    viewDecoder =
      let
        rowDecoder =
          Decode.map3 Row
            (Decode.field "id" Decode.string)
            (Decode.field "key" keyDecoder)
            (Decode.field "value" valueDecoder)
      in
        Decode.field "rows" (Decode.list rowDecoder)
  in
    Http.get fetchAddr viewDecoder


view :
  Decode.Decoder key
  -> Decode.Decoder value
  -> Config
  -> String
  -> String
  -> Http.Request (List (Row key value))
view keyDecoder valueDecoder config designName viewName =
  let
    viewPath =
      makePath
        [ "_design"
        , designName
        , "_view"
        , viewName
        ]
  in
    specialView keyDecoder valueDecoder config viewPath


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
