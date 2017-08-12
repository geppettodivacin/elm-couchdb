import Http
import Html exposing (..)
import Html.Events exposing (..)
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



--
-- Demonstration
--


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
  | Error 
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
          Debug.log (toString error) error |> always Error
  in
    Http.send parseResult req


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Retrieved doc ->
      ({model | doc = Just doc}, Cmd.none)
    
    Fetch ->
      (model, fetchCmd)

    Error ->
      ({model | doc = Nothing}, Cmd.none)


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1  [] [ text (toString model.doc) ]
    , button [ onClick Fetch ] [ text "Fetch" ]
    ]
