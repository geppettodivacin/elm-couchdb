module Couchdb.View exposing (Options, initOptions, Row, key, start_key, end_key, viewWith, specialViewWith)

{-|
# Views with options
@docs Row, viewWith, specialViewWith

# Options
@docs Options, initOptions, key, start_key, end_key
-}
import Http
import Json.Encode as Encode
import Json.Decode as Decode

import Couchdb.Internal exposing (..)


{-| Type for view options.
-}
type alias Options =
    { key : Maybe String
    , start_key : Maybe String
    , end_key : Maybe String
    }


{-| Blank set of options.
-}
initOptions : Options
initOptions = Options Nothing Nothing Nothing


optionsString : Options -> String
optionsString options =
  let
    existingOptions =
      List.filterMap identity <|
        [ Maybe.map (\k -> "key=" ++ k) options.key
        , Maybe.map (\k -> "start_key=" ++ k) options.start_key
        , Maybe.map (\k -> "end_key=" ++ k) options.end_key
        ]
  in
    if List.isEmpty existingOptions then
      ""
    else
      "?" ++ (String.concat <| List.intersperse "&" existingOptions)


{-| Add "key" option for query.
-}
key : Encode.Value -> Options -> Options
key value options =
  {options | key = Just <| Encode.encode 0 value}


{-| Add "start_key" option for query.
-}
start_key : Encode.Value -> Options -> Options
start_key value options =
  {options | start_key = Just <| Encode.encode 0 value}


{-| Add "end_key" option for query.
-}
end_key : Encode.Value -> Options -> Options
end_key value options =
  {options | end_key = Just <| Encode.encode 0 value}


{-| Row in a view. Contains `.id`, `.key`, and `.value`.
-}
type alias Row key value =
    { id : String
    , key : key
    , value : value
    }


{-| Create a request for a view in a design document with the specified
options. In order to extract the rows from the response, you must
provide a JSON decoder for the key and for the value.
-}
viewWith :
  Options
  -> Decode.Decoder key
  -> Decode.Decoder value
  -> Database
  -> String
  -> String
  -> Http.Request (List (Row key value))
viewWith options keyDecoder valueDecoder db designName viewName =
  let
    viewPath =
      makePath
        [ "_design"
        , designName
        , "_view"
        , viewName
        ]
  in
    specialViewWith options keyDecoder valueDecoder db viewPath


{-| Create a request for a view at a particular path with the specified
options.
-}
specialViewWith :
  Options
  -> Decode.Decoder key
  -> Decode.Decoder value
  -> Database
  -> String
  -> Http.Request (List (Row key value))
specialViewWith options keyDecoder valueDecoder db viewPath =
  let
    path =
      makePath [databaseString db, viewPath]

    fetchAddr =
      path ++ optionsString options

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
