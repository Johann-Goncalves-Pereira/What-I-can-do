module Pages.Home_ exposing (Model, Msg, page, subs)

import Array exposing (Array)
import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Html, a, div, h1, h2, h5, p, section, span, text)
import Html.Attributes exposing (class, href, id, rel, style, tabindex, target)
import Html.Attributes.Aria exposing (ariaLabel, ariaLabelledby)
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

    -- Title
    , titleIndex : Int

    -- Typing Title
    , timePass : Int
    , typingRandomTime : Float
    , timerState : TimerState
    }


init : ( Model, Cmd Msg )
init =
    ( { headerSize = 18
      , titleIndex = 0
      , timePass = 0
      , typingRandomTime = 10
      , timerState = TimerGoingUp
      }
    , Cmd.batch
        [ BrowserDom.getElement headerClass |> Task.attempt GotHeader
        , run GetTitle
        ]
    )


type TimerState
    = TimerGoingUp
    | TimerGoingDown



-- UPDATE


type Msg
    = -- Header
      GotHeader (Result Error Element)
      -- Title
    | GetTitle
    | NewTitle Int
      -- Typing Time
    | RandomTimeTyping
    | NewTimeTyping Float
    | ChangeTimerState TimerState
      -- Typing Title
    | TypingTimeAdd
    | TypingTimeSub


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

        RandomTimeTyping ->
            ( model, Random.generate NewTimeTyping (Random.float 1 4) )

        NewTimeTyping t ->
            ( { model | typingRandomTime = t }, Cmd.none )

        ChangeTimerState ts ->
            case ts of
                TimerGoingUp ->
                    ( { model | timerState = TimerGoingDown }, Cmd.none )

                TimerGoingDown ->
                    ( { model | timerState = TimerGoingUp }, Cmd.none )

        TypingTimeAdd ->
            if model.timePass < getTitleChAmount model then
                ( { model | timePass = model.timePass + 1 }
                , Cmd.none
                )

            else
                ( model, run <| ChangeTimerState model.timerState )

        TypingTimeSub ->
            if model.timePass > 0 then
                ( { model | timePass = model.timePass - 1 }
                , Cmd.none
                )

            else
                ( model, run <| ChangeTimerState model.timerState )


run : Msg -> Cmd Msg
run m =
    Task.perform (always m) (Task.succeed ())



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    let
        eraserPace =
            if model.timePass < 3 then
                4

            else
                1
    in
    Sub.batch
        [ case model.timerState of
            TimerGoingUp ->
                Time.every (60 * model.typingRandomTime) (\_ -> TypingTimeAdd)

            TimerGoingDown ->
                Time.every (60 * eraserPace) (\_ -> TypingTimeSub)
        , Time.every (60 * 10) (\_ -> RandomTimeTyping)
        ]



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
    , "Hello, universe and everything and everything and everything and everything!"
    ]


getPossibleTitles : Int -> String
getPossibleTitles index =
    Array.fromList introTitles
        |> Array.get index
        |> Maybe.withDefault "Hi, I am a robot!"


getTitleChAmount : Model -> Int
getTitleChAmount model =
    getPossibleTitles model.titleIndex
        |> String.length


viewIntro : Model -> Html Msg
viewIntro model =
    let
        slicer : Int -> Int -> String
        slicer index typing =
            getPossibleTitles index
                |> String.slice 0 typing
    in
    section [ class "intro" ]
        [ h1 [ class "intro__title", ariaLabel <| getPossibleTitles model.titleIndex ]
            [ text <| slicer model.titleIndex model.timePass
            ]
        ]
