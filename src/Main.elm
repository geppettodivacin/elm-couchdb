import Http
import Native
import Json.Decode as Decode
import Json.Encode as Encode

type alias Config =
    { host : String
    , db : String
    }


fetch :
  Decode.Decoder a
  -> (Result Http.Error a -> msg)
  -> Config
  -> String
  -> Cmd msg
fetch decoder toMsg config key =
  let
    fetchAddr =
      configString config ++ "/" ++ key
  in
      Http.send toMsg (Http.get fetchAddr decoder)


store :
  (a -> Encode.Value)
  -> msg
  -> Config
  -> String
  -> a
  -> Maybe String
  -> Cmd msg
store encode msg config key value revision =
  let
    postAddr =
      configString config ++ "/" ++ key
    msg = Encode.encode 0 (encode value |> withRev revision)
  in
    Cmd.none

withRev : Maybe String -> Encode.Value -> Encode.Value
withRev = Native.withRev

configString : Config -> String
configString config =
  config.host ++ config.db
