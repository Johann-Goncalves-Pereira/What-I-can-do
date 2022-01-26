module UI exposing (layout)

import Gen.Route as Route exposing (Route)
import Html exposing (Html, a, button, header, li, main_, nav, text, ul)
import Html.Attributes exposing (class, classList, href)
import Platform exposing (Router)


isRoute : Route -> Route -> Bool
isRoute route compare =
    case ( route, compare ) of
        ( Route.Home_, Route.Home_ ) ->
            True

        ( Route.Layout__Music, Route.Layout__Music ) ->
            True

        _ ->
            False


layout : Route -> String -> List (Html msg) -> List (Html msg)
layout route pageName content =
    let
        viewLink : String -> Route -> Html msg
        viewLink label routes =
            li [ class "main-header__list__item" ]
                [ a
                    [ href <| Route.toHref routes
                    , classList
                        [ ( "main-header__list__item__links", True )
                        , ( "main-header__list__item__links--current-page"
                          , isRoute route routes
                          )
                        ]
                    ]
                    [ text label ]
                ]
    in
    [ header [ class "main-header" ]
        [ nav [ class "main-header__nav" ]
            [ viewLink "Home" Route.Home_
            , ul [ class "main-header__list" ]
                [ viewLink "Music" Route.Layout__Music
                ]
            ]
        ]
    , main_ [ class <| "main--" ++ pageName ] content
    ]
