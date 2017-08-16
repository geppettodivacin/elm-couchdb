import Json.Decode as Decode
import Json.Encode as Encode
import Html exposing (..)
import Html.Events exposing (..)
import Http

import Couchdb exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }


-- MODEL


type alias Model =
  { doc : Maybe Document
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
  = Retrieved Document
  | Error Http.Error
  | Fetch


fetchCmd : Cmd Msg
fetchCmd =
  let
    config = Config "localhost:5984" "elm-example"

    id = "fetchdoc"

    req = fetch docDecoder config id

    parseResult result =
      case result of
        Ok doc ->
          Retrieved doc

        Err error ->
          Debug.log (toString error) error |> Error
  in
    Http.send parseResult req


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Retrieved doc ->
      ({model | doc = Just doc}, Cmd.none)
    
    Fetch ->
      (model, fetchCmd)

    Error _ ->
      ({model | doc = Nothing}, Cmd.none)


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1  [] [ text (toString model.doc) ]
    , button [ onClick Fetch ] [ text "Fetch" ]
    ]
