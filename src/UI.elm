module UI exposing (layout)

import Gen.Route as Route exposing (Route)
import Html exposing (Html, a, button, header, main_, nav, text)
import Html.Attributes exposing (class, classList, href)


isRoute : Route -> Route -> Bool
isRoute route compare =
    case ( route, compare ) of
        ( Route.Home_, Route.Home_ ) ->
            True

        _ ->
            False


layout : Route -> List (Html msg) -> List (Html msg)
layout route children =
    let
        viewLink : String -> Route -> Html msg
        viewLink label routes =
            a
                [ href <| Route.toHref routes
                , class "main-header__links"
                , classList
                    [ ( "main-header__links--current-page"
                      , isRoute route routes
                      )
                    ]
                ]
                [ text label ]
    in
    [ header [ class "main-header" ]
        [ nav [ class "main-header__nav" ]
            [ viewLink "Home" Route.Home_
            , nav [ class "main-header__nav--small" ]
                []
            ]
        ]
    , main_ [] children
    ]
