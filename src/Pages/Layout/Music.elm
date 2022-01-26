module Pages.Layout.Music exposing (Model, Msg, page)

import Gen.Params.Layout.Music exposing (Params)
import Gen.Route as Route exposing (Route)
import Html exposing (Html, div, h1, img, li, section, text, ul)
import Html.Attributes exposing (class, classList)
import Page
import Request
import Shared
import Svg.Music as SvgMusic
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    { route : Route }


init : Model
init =
    { route = Route.Layout__Music }



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> Model
update msg model =
    case msg of
        ReplaceMe ->
            model



-- VIEW


view : Model -> View Msg
view model =
    { title = "Johann - Home"
    , body =
        UI.layout model.route
            "music"
            [ sidebar
            ]
    }


sidebar : Html msg
sidebar =
    section [ class "sidebar" ]
        [ div [ class "sidebar__main-info" ]
            [ SvgMusic.headphones "icon"
            , h1 [ class "app-name" ] [ text "Podland" ]
            ]
        , ul [ class "sidebar__list" ]
            [ li
                [ classList
                    [ ( "sidebar__list__item", True )
                    , ( "selected", True )
                    ]
                ]
                [ SvgMusic.compass
                , text "Discovery"
                ]
            , li
                [ classList
                    [ ( "sidebar__list__item", True )
                    , ( "selected", False )
                    ]
                ]
                [ SvgMusic.compass
                , text "Discovery"
                ]
            , li
                [ classList
                    [ ( "sidebar__list__item", True )
                    , ( "selected", False )
                    ]
                ]
                [ SvgMusic.shopCart
                , text "Discovery"
                ]
            , li
                [ classList
                    [ ( "sidebar__list__item", True )
                    , ( "selected", False )
                    ]
                ]
                [ SvgMusic.compass
                , text "Discovery"
                ]
            , li
                [ classList
                    [ ( "sidebar__list__item", True )
                    , ( "selected", False )
                    ]
                ]
                [ SvgMusic.compass
                , text "Discovery"
                ]
            ]
        ]
