module Svg.ElmSvg exposing (..)

import Html exposing (Html)
import Svg exposing (defs, g, path, rect, svg)
import Svg.Attributes exposing (..)


type Colors
    = Background
    | Text


fillColor : Colors -> String
fillColor clr =
    case clr of
        Background ->
            "var(--clr-background, #040014)"

        Text ->
            "var(--clr-text, #f9f8ff)"


twoArrows : Colors -> Html msg
twoArrows clrs =
    svg [ viewBox "0 0 30 30" ]
        [ Svg.path
            [ d "M 14.984375 5 A 1.0001 1.0001 0 0 0 14.292969 5.2929688 L 4.2929688 15.292969 A 1.0001 1.0001 0 1 0 5.7070312 16.707031 L 15 7.4140625 L 24.292969 16.707031 A 1.0001 1.0001 0 1 0 25.707031 15.292969 L 15.707031 5.2929688 A 1.0001 1.0001 0 0 0 14.984375 5 z M 14.984375 12 A 1.0001 1.0001 0 0 0 14.292969 12.292969 L 4.2929688 22.292969 A 1.0001 1.0001 0 1 0 5.7070312 23.707031 L 15 14.414062 L 24.292969 23.707031 A 1.0001 1.0001 0 1 0 25.707031 22.292969 L 15.707031 12.292969 A 1.0001 1.0001 0 0 0 14.984375 12 z"
            , fill <| fillColor clrs
            ]
            []
        ]
