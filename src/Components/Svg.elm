module Components.Svg exposing (..)

import Html exposing (Html)
import Svg
    exposing
        ( circle
        , defs
        , feComposite
        , feFlood
        , feGaussianBlur
        , feMorphology
        , feOffset
        , g
        , line
        , linearGradient
        , polygon
        , rect
        , svg
        , use
        )
import Svg.Attributes as Sa exposing (..)


type Home
    = Intro
