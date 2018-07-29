module TeamInfo (getMembers) where

import qualified Data.Map.Strict as M

type Member = String
type MemberInfo = (String, Int)

getMembers :: M.Map Member [MemberInfo]
getMembers = M.fromList
    [ ("José Breno",
        [ ("Heap", 35), ("Web-back", 75), ("Web-front", 90)]
      )
    , ("Ronaldo Pessoa",
        [ ("Heap", 75), ("Web-back", 25), ("Web-front", 10)]
      )
    ]