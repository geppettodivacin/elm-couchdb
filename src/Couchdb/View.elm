module Couchdb.View exposing (Settings, settings, key, start_key, end_key, viewWith, specialViewWith)

{-|
@docs Settings, settings, key, start_key, end_key, viewWith, specialViewWith
-}
import Http
import Json.Encode as Encode
import Json.Decode as Decode

import Couchdb.Internal exposing (..)


{-|-}
type alias Settings =
    { key : Maybe String
    , start_key : Maybe String
    , end_key : Maybe String
    }


{-|-}
settings : Settings
settings = Settings Nothing Nothing Nothing


settingsString : Settings -> String
settingsString settings =
  let
    allSettings =
      List.filterMap identity <|
        [ Maybe.map (\k -> "key=" ++ k) settings.key
        , Maybe.map (\k -> "start_key=" ++ k) settings.start_key
        , Maybe.map (\k -> "end_key=" ++ k) settings.end_key
        ]
  in
    if List.isEmpty allSettings then
      ""
    else
      "?" ++ (String.concat <| List.intersperse "&" allSettings)


{-|-}
key : Encode.Value -> Settings -> Settings
key value settings =
  {settings | key = Just <| Encode.encode 0 value}


{-|-}
start_key : Encode.Value -> Settings -> Settings
start_key value settings =
  {settings | start_key = Just <| Encode.encode 0 value}


{-|-}
end_key : Encode.Value -> Settings -> Settings
end_key value settings =
  {settings | end_key = Just <| Encode.encode 0 value}


{-|-}
viewWith :
  Settings
  -> Decode.Decoder key
  -> Decode.Decoder value
  -> Config
  -> String
  -> String
  -> Http.Request (List (Row key value))
viewWith settings keyDecoder valueDecoder config designName viewName =
  let
    viewPath =
      makePath
        [ "_design"
        , designName
        , "_view"
        , viewName
        ]
  in
    specialViewWith settings keyDecoder valueDecoder config viewPath


{-|-}
specialViewWith :
  Settings
  -> Decode.Decoder key
  -> Decode.Decoder value
  -> Config
  -> String
  -> Http.Request (List (Row key value))
specialViewWith settings keyDecoder valueDecoder config viewPath =
  let
    path =
      makePath [configString config, viewPath]

    fetchAddr =
      path ++ settingsString settings

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
