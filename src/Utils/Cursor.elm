module Utils.Cursor exposing (Model, Msg(..), init, update)


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
