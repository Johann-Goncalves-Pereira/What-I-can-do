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
    | CursorViewToggler Bool


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

        CursorViewToggler show ->
            { model
                | mouseCursorShow = show
            }
