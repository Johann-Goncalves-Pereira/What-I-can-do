module Utils.Cursor exposing (..)

import Html exposing (Attribute, Html, div)
import Html.Events
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Decode exposing (Decoder)


type alias EventWithMovement =
    { mouseEvent : Mouse.Event
    , movement : ( Float, Float )
    }


type alias Model =
    { mouseClientPosition : { x : Float, y : Float }
    }


init : Model
init =
    { mouseClientPosition = { x = 0, y = 0 } }


type Msg
    = ClientMovement ( Float, Float )


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


onMove : (EventWithMovement -> Msg) -> Html.Attribute Msg
onMove tag =
    let
        decoder =
            decodeWithMovement
                |> Decode.map tag
                |> Decode.map options

        options message =
            { message = message
            , stopPropagation = False
            , preventDefault = True
            }
    in
    Html.Events.custom "mousemove" decoder


decodeWithMovement : Decoder EventWithMovement
decodeWithMovement =
    Decode.map2 EventWithMovement
        Mouse.eventDecoder
        movementDecoder


movementDecoder : Decoder ( Float, Float )
movementDecoder =
    Decode.map2 (\a b -> ( a, b ))
        (Decode.field "movementX" Decode.float)
        (Decode.field "movementY" Decode.float)


cursor : List (Attribute Msg) -> Maybe (List (Html Msg)) -> Html Msg
cursor attrs content =
    --? Mouse.onMove (.clientPos >> ClientMovement)
    div attrs
        (Maybe.withDefault [] content)
