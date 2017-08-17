import Json.Decode as Decode
import Json.Encode as Encode
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Task

import Couchdb exposing (..)
import Couchdb.View as View


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }


-- MODEL


type alias Model =
  { docs : Maybe (List (Couchdb.Row String String))
  }


type alias Document =
  { id : String
  , rev : String
  , value : String
  }


docDecoder : Decode.Decoder Document
docDecoder =
  Decode.map3 Document
    (Decode.field "_id" Decode.string)
    (Decode.field "_rev" Decode.string)
    (Decode.field "value" Decode.string)


init =
  (Model Nothing, Cmd.none)


-- UPDATE


type Msg
  = Retrieved (List (Couchdb.Row String String))
  | Error Http.Error
  | Fetch


fetchCmd : Cmd Msg
fetchCmd =
  let
    config =
      defineDb "localhost:5984" "elm-example"

    designName =
      "designs"

    viewName =
      "values"

    settings =
      View.settings |> View.key (Encode.string "fetchdoc")

    req =
      View.viewWith settings
        Decode.string
        Decode.string
        config
        designName
        viewName

    parseResult result =
      case result of
        Ok docs ->
          Retrieved docs

        Err error ->
          Debug.log "Error" error |> Error
  in
    Http.send parseResult req


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Retrieved docs ->
      ({model | docs = Just docs}, Cmd.none)
    
    Fetch ->
      (model, fetchCmd)

    Error _ ->
      ({model | docs = Nothing}, Cmd.none)


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ text (toString model.docs)
    , br [] []
    , button [ onClick Fetch ] [ text "Fetch" ]
    ]
