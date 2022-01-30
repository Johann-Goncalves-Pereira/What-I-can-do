module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route exposing (Route)
import Html exposing (Html, a, article, b, br, button, div, em, h1, h2, h3, img, main_, p, section, span, strong, text)
import Html.Attributes exposing (attribute, class, id, src, style)
import Html.Events exposing (onClick)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import Svg.ElmSvg as ESvg
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
    { route : Route
    }


init : Model
init =
    { route = Route.Home_
    }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            { model | route = model.route }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Johann - Home"
    , body =
        UI.layout model.route
            "home"
            [ section [ class "shallow--down ctnr weather" ]
                [ p [ class "ctnr__text weather__txt--n" ]
                    [ strong [ class "ctnr__text__title" ] [ text "26" ]
                    , b [ class "ctnr__text__medium" ] [ text "Clear" ]
                    ]
                , p [ class "weather__txt--s" ]
                    [ em [] [ text "Curitiba City, Brasil" ]
                    , text "position: fixed; bottom: 2em; right: 2em; width: calc(42px + 3ch); height: 36px; background-color: rgb(18, 147, 216); "
                    ]
                ]
            , div [ class "ctnr__btm--fc" ]
                [ button [ class "shallow--up btm" ] [ ESvg.home ESvg.SvgInvertArrows ]
                , button [ class "shallow--up btm" ] [ ESvg.home ESvg.SvgPlus ]
                ]
            , div [ class "ctnr__btm--fr" ]
                [ button [ class "shallow--up btm" ] [ ESvg.home <| ESvg.SvgArrow ESvg.Right ]
                , button [ class "shallow--up btm" ] [ ESvg.home <| ESvg.SvgArrow ESvg.Left ]
                , button [ class "shallow--up btm" ] [ ESvg.home ESvg.SvgFlag ]
                ]
            , section [ class "shallow--down ctnr__btm--fr line-btm" ]
                [ button [ class "line-btm__btm" ] [ ESvg.home ESvg.SvgDollar ]
                , button [ class "line-btm__btm" ] [ ESvg.home ESvg.SvgPerson ]
                , button [ class "line-btm__btm" ] [ ESvg.home ESvg.SvgShoppingCart ]
                , button [ class "line-btm__btm" ] [ ESvg.home ESvg.SvgInformation ]
                , button [ class "line-btm__btm shallow--up btm" ] [ em [] [ text "Change" ] ]
                ]

            -- , section [ class "shallow--up" ] []
            ]
    }
