module Couchdb.Internal exposing (Config, defineDb, Row, makePath, configString)


type alias Config =
    { host : String
    , db : String
    }


defineDb : String -> String -> Config
defineDb = Config


type alias Row key value =
    { id : String
    , key : key
    , value : value
    }


makePath : List String -> String
makePath parts =
  String.concat (List.intersperse "/" parts)


configString : Config -> String
configString config =
  "http://" ++ config.host ++ "/" ++ config.db
