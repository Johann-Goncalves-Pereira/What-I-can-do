module Pages.Home_ exposing (Model, Msg, page)

import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Html, a, div, h1, h2, h5, section, text)
import Html.Attributes exposing (class, href, id, rel, tabindex, target)
import Html.Attributes.Aria exposing (ariaLabel, ariaLabelledby)
import Layout exposing (pageConfig)
import Page
import Platform exposing (Task)
import Request
import Shared
import Svg exposing (desc)
import Task
import Utils.View exposing (customProps)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        }



-- INIT


type alias Model =
    { headerSize : Int }


init : ( Model, Cmd Msg )
init =
    ( { headerSize = 64 }
    , BrowserDom.getElement "root__header" |> Task.attempt GotHeader
    )



-- UPDATE


type Msg
    = -- Header
      GotHeader (Result Error Element)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotHeader promiseResponse ->
            case promiseResponse of
                Err _ ->
                    ( model, Cmd.none )

                Ok element ->
                    ( { model | headerSize = round element.element.height }, Cmd.none )



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Home"
    , body = viewLayout model
    }


viewLayout : Model -> List (Html Msg)
viewLayout model =
    Layout.layout
        { pageConfig
            | route = Route.Home_
            , mainAttrs =
                [ customProps [ { prop = "header-height", value = String.fromInt model.headerSize ++ "px" } ]
                ]
            , mainContent = []
        }
