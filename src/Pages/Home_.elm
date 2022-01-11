module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route exposing (Route)
import Html exposing (Html, a, article, b, br, div, h1, h2, h3, img, main_, p, section, span, strong, text)
import Html.Attributes exposing (attribute, class, id, src, style)
import Html.Events exposing (onClick)
import Page exposing (Page)
import Preview.Kelpie.Kelpie as Kelpie exposing (view)
import Request exposing (Request)
import Shared
import Svg.Base as MSvg
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
    , scrollSample : Bool
    }


init : Model
init =
    { route = Route.Home_
    , scrollSample = False
    }



-- UPDATE


type Msg
    = ShowSample


update : Msg -> Model -> Model
update msg model =
    case msg of
        ShowSample ->
            { model | scrollSample = not model.scrollSample }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Johann - Home"
    , body =
        UI.layout model.route
            [ viewMainContent
            ]
    }



-- Main Content


viewMainContent : Html Msg
viewMainContent =
    main_ [ class "main-home" ]
        []
