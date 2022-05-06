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

    -- Typing Title
    , titleIndex : Int
    , typingTimeChar : Int
    , typingRandomPace : Float
    , timerState : TimerState
    , typingReset : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { headerSize = 18
      , titleIndex = 0
      , typingTimeChar = 0
      , typingRandomPace = 10
      , timerState = TimerGoingUp
      , typingReset = False
      }
    , Cmd.batch
        [ BrowserDom.getElement headerClass
            |> Task.attempt GotHeader

        -- , run GetTitle
        ]
    )



-- UPDATE


type TimerState
    = TimerGoingUp
    | TimerGoingDown
    | TimerBridge Bool
    | TimerReset
    | TimerStop


type Msg
    = -- Header
      GotHeader (Result Error Element)
      -- Title
      -- | GetTitle
      -- | NewTitle Int
      -- Typing Time
    | RandomTypingPace
    | NewTypingPace Float
    | ChangeTimerState TimerState
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
                    ( { model | headerSize = round element.element.height }
                    , Cmd.none
                    )

        RandomTypingPace ->
            ( model, Random.generate NewTypingPace (Random.float 1 3) )

        NewTypingPace t ->
            ( { model | typingRandomPace = t }, Cmd.none )

        ChangeTimerState ts ->
            let
                checkIfListOfTitlesIsFull =
                    model.titleIndex >= List.length introTitles - 1 && model.typingReset == False

                stopTyping timingState =
                    if checkIfListOfTitlesIsFull then
                        TimerStop

                    else
                        timingState
            in
            case ts of
                TimerGoingUp ->
                    ( { model | timerState = stopTyping TimerGoingDown }, Cmd.none )

                TimerGoingDown ->
                    ( { model | timerState = TimerBridge model.typingReset }, Cmd.none )

                TimerBridge reset ->
                    let
                        timeReset =
                            if reset then
                                0

                            else
                                model.titleIndex + 1
                    in
                    ( { model
                        | timerState = stopTyping TimerGoingUp
                        , titleIndex = timeReset
                        , typingReset = False
                      }
                    , Cmd.none
                    )

                TimerReset ->
                    ( { model
                        | timerState = TimerBridge True
                        , typingReset = True
                      }
                    , Cmd.none
                    )

                TimerStop ->
                    ( model, Cmd.none )

        TypingTimeAdd ->
            if model.typingTimeChar < getTitleCharAmount model - 1 then
                ( { model | typingTimeChar = model.typingTimeChar + 1 }
                , Cmd.none
                )

            else if model.typingTimeChar < getTitleCharAmount model then
                ( { model | typingTimeChar = model.typingTimeChar + 1 }
                , run <| ChangeTimerState model.timerState
                )

            else
                ( model, run <| ChangeTimerState model.timerState )

        TypingTimeSub ->
            if model.typingTimeChar > 0 then
                ( { model | typingTimeChar = model.typingTimeChar - 1 }
                , Cmd.none
                )

            else
                ( model, run <| ChangeTimerState model.timerState )


run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    let
        eraserPace =
            if model.typingTimeChar < 3 then
                4

            else if model.typingTimeChar == getTitleCharAmount model then
                8

            else
                1
    in
    Sub.batch
        [ case model.timerState of
            TimerGoingUp ->
                Sub.batch
                    [ Time.every (60 * model.typingRandomPace) (\_ -> TypingTimeAdd)
                    , Time.every (60 * 10) (\_ -> RandomTypingPace)
                    ]

            TimerGoingDown ->
                Time.every (60 * eraserPace) (\_ -> TypingTimeSub)

            TimerBridge _ ->
                Time.every (60 * 0) (\_ -> TypingTimeSub)

            TimerReset ->
                Sub.none

            TimerStop ->
                Sub.none
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
    [ "Hi, I'm Johann"
    , "I'm a software developer"
    , "I work at the web"
    , "I Love Code, UI and Design"
    , "So let's work together"
    ]


getTitle : Int -> String
getTitle index =
    Array.fromList introTitles
        |> Array.get index
        |> Maybe.withDefault "Hi, I am a robot!"


getTitleCharAmount : Model -> Int
getTitleCharAmount model =
    getTitle model.titleIndex
        |> String.length


viewIntro : Model -> Html Msg
viewIntro model =
    let
        slicer : Int -> Int -> String
        slicer index typing =
            getTitle index
                |> String.slice 0 typing
    in
    section [ class "intro" ]
        [ h1
            [ class "intro__title"
            , ariaLabel <| getTitle model.titleIndex
            , onClick <| ChangeTimerState TimerReset
            ]
            [ text <| slicer model.titleIndex model.typingTimeChar
            ]
        ]
