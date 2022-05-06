module Pages.Home_ exposing (Model, Msg, page)

import Array exposing (Array)
import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Html, a, div, h1, h2, h5, section, text)
import Html.Attributes exposing (class, href, id, rel, tabindex, target)
import Html.Attributes.Aria exposing (ariaLabel, ariaLabelledby)
import Layout exposing (pageConfig)
import Page
import Platform exposing (Task)
import Random
import Request
import Shared
import Svg exposing (desc)
import Task
import Time exposing (Posix, every, millisToPosix, posixToMillis)
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
    { headerSize : Int
    , titleIndex : Int
    , timePass : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { headerSize = 64
      , titleIndex = 0
      , timePass = 0
      }
    , Cmd.batch
        [ BrowserDom.getElement "root__header" |> Task.attempt GotHeader
        , run GetTitle
        ]
    )



-- UPDATE


type Msg
    = -- Header
      GotHeader (Result Error Element)
      -- Title
    | GetTitle
    | NewTitle Int
      -- Typing
    | TypingTime


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotHeader promiseResponse ->
            case promiseResponse of
                Err _ ->
                    ( model, Cmd.none )

                Ok element ->
                    ( { model | headerSize = round element.element.height }, Cmd.none )

        GetTitle ->
            ( model, Random.generate NewTitle (Random.int 0 <| List.length introTitles - 1) )

        NewTitle index ->
            ( { model | titleIndex = index }, Cmd.none )

        TypingTime ->
            ( { model | timePass = model.timePass + 1 }, Cmd.none )


run : Msg -> Cmd Msg
run m =
    Task.perform (always m) (Task.succeed ())



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    Time.every 60 (\_ -> TypingTime)



-- every (toFloat (posixToMillis model.pos)) (always TypingTime)
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
    [ "Hello, world!"
    , "Hello, universe!"
    , "Hello, universe and everything!"
    , "Hello, universe and everything and everything!"
    , "Hello, universe and everything and everything and everything!"
    , "Hello, universe and everything and everything and everything and everything!"
    ]


viewIntro : Model -> Html Msg
viewIntro model =
    let
        nameHeader : String
        nameHeader =
            "intro-head"

        getPossibleTitles : Int -> String
        getPossibleTitles index =
            Array.fromList introTitles
                |> Array.get index
                |> Maybe.withDefault "Hi, I am a robot!"

        slicer : Int -> Int -> String
        slicer index typing =
            getPossibleTitles index
                |> String.slice 0 typing
    in
    section [ class "intro", ariaLabelledby nameHeader ]
        [ h1 [ class "intro__title", id nameHeader ]
            [ slicer model.titleIndex 50
                |> text
            ]
        , text <| String.fromInt model.timePass
        ]
