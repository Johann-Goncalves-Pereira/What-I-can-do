module Utils.Cursor exposing (Model, Msg(..), cursor, init, update)

import Html exposing (Attribute, Html, div)


type alias Model =
    { mouseClientPosition : { x : Float, y : Float }
    , mouseCursorShow : Bool
    }


init : Model
init =
    { mouseClientPosition = { x = 0, y = 0 }
    , mouseCursorShow = False
    }


type Msg
    = ClientMovement ( Float, Float )
    | CursorShow
    | CursorHide


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClientMovement ( x, y ) ->
            { model
                | mouseClientPosition =
                    { x = x
                    , y = y
                    }
            }

        CursorShow ->
            { model
                | mouseCursorShow = True
            }

        CursorHide ->
            { model
                | mouseCursorShow = False
            }


cursor : List (Attribute Msg) -> List (Html Msg) -> Html Msg
cursor attrs content =
    --? Mouse.onMove (.clientPos >> ClientMovement)
    div attrs content
