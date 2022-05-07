module Pages.Home_ exposing (Model, Msg, page, subs)

import Array exposing (Array)
import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Html, a, div, h1, h2, h5, p, section, span, text)
import Html.Attributes exposing (class, href, id, rel, style, tabindex, target)
import Html.Attributes.Aria exposing (ariaLabel, ariaLabelledby)
import Html.Events exposing (onClick)
import Layout exposing (headerClass, pageConfig)
import Page
import Platform exposing (Task)
import Random
import Request
import Round exposing (floorNumCom)
import Shared
import Svg exposing (desc)
import Task
import Time exposing (Posix, every, millisToPosix, posixToMillis)
import Utils.TaskBase exposing (run)
import Utils.Typing as Typing
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
    { -- Header
      headerSize : Int
    , typingModel : Typing.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { headerSize = 18
      , typingModel = Typing.init
      }
    , Cmd.batch
        [ BrowserDom.getElement headerClass
            |> Task.attempt GotHeader
        ]
    )



-- UPDATE


type Msg
    = -- Header
      GotHeader (Result Error Element)
    | TypingMsg Typing.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotHeader promiseResponse ->
            case promiseResponse of
                Err _ ->
                    ( model, Cmd.none )

                Ok element ->
                    ( { model | headerSize = round element.element.height }
                    , Cmd.none
                    )

        TypingMsg typingMsg ->
            let
                ( typingModel, typingCmd ) =
                    Typing.update typingMsg model.typingModel
            in
            ( { model | typingModel = typingModel }
            , Cmd.map TypingMsg typingCmd
            )



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    let
        typingSub =
            Typing.subs model.typingModel
    in
    Sub.map TypingMsg typingSub



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
                [ customProps
                    [ { prop = "header-height"
                      , value = String.fromInt model.headerSize ++ "px"
                      }
                    ]
                ]
            , mainContent = [ viewIntro model ]
        }


introTitles : List String
introTitles =
    [ "Hi, I'm Johann"
    , "I'm a software developer"
    , "I work at the web"
    , "I Love Code, UI and Design"
    , "So let's work together"
    ]


viewIntro : Model -> Html Msg
viewIntro model =
    let
        m =
            model.typingModel
    in
    section [ class "intro" ]
        [ h1
            [ class "intro__title"
            , ariaLabel <| Typing.getTitle m m.titleIndex
            , Typing.ChangeTimerState Typing.Reset
                |> TypingMsg
                |> onClick
            ]
            [ text <| Typing.slicer m m.titleIndex m.typingTimeChar
            ]
        ]
