module Room exposing (Model, Msg, init, update, view, serializer, deserializer, Msg(..))

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Helper exposing (message)
import Json.Encode as JsonEnc
import Json.Decode as JsonDec exposing ((:=), Decoder)
import Json.Decode.Extra exposing((|:))
import Monster

-- MODEL
type alias Model =
  { clicks : Int
  , currentMonster : Monster.Model
  }

init : Model
init = 
  { clicks = 0
  , currentMonster = Monster.init
  }

-- UPDATE
type Msg
  = Logout
  | Deauthenticated
  | MonsterClick
  | RmMonster Monster.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    Logout ->          model ! [message Deauthenticated]
    Deauthenticated -> model ! [] -- Handler if not captured by parent
    MonsterClick -> 
      let
        (data, command) = Monster.update Monster.Attacked model.currentMonster
      in
        ({model | currentMonster = data}, Cmd.map RmMonster command)
    RmMonster cmd ->
      let
        (data, command) = Monster.update cmd model.currentMonster
      in
        ({model | currentMonster = data}, Cmd.map RmMonster command)

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick Logout ] [ text "logout" ]
    , viewMonster model
    , displayClicks model
    ]


-- HELPERS

viewMonster : Model -> Html Msg
viewMonster model =
  div []
    [ div [] 
      [ text model.currentMonster.monster.monsterBase.name
      ]
    , div [] 
      [ img [ src model.currentMonster.monster.monsterBase.image, height 128, width 128, onClick MonsterClick] []
      ]
    ]

displayClicks : Model -> Html Msg
displayClicks model =
  div []
    [ text <| "Hitpoints: " ++ toString model.currentMonster.monster.hitPoints]


-- SERIALIZATION

serializer : Model -> JsonEnc.Value
serializer model =
  JsonEnc.object
    [ ("clicks", JsonEnc.int model.clicks)
    , ("currentMonster", Monster.serializer model.currentMonster)
    ]

deserializer : Decoder Model
deserializer =
  JsonDec.succeed Model
    |: ("clicks"         := JsonDec.int)
    |: ("currentMonster" := Monster.deserializer)