module Couchdb.Internal exposing (Database, defineDb, makePath, databaseString)


type alias Database =
    { host : String
    , db : String
    }


defineDb : String -> String -> Database
defineDb = Database


makePath : List String -> String
makePath parts =
  String.concat (List.intersperse "/" parts)


databaseString : Database -> String
databaseString db =
  "http://" ++ db.host ++ "/" ++ db.db
