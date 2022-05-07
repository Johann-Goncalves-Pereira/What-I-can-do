module Utils.Typing exposing (..)

import Array
import Html exposing (Attribute, Html, text)
import Html.Attributes exposing (style)
import Html.Attributes.Aria exposing (ariaLabel)
import Html.Events exposing (onClick)
import Random
import Svg exposing (cursor)
import Time
import Utils.TaskBase exposing (run)



-- INIT


type alias Model =
    { titleList : List String
    , titleIndex : Int
    , typingTimeChar : Int
    , typingRandomPace : Float
    , timerState : TimerState
    , typingReset : Bool
    }


init : Model
init =
    { titleList = []
    , titleIndex = 0
    , typingTimeChar = 0
    , typingRandomPace = 10
    , timerState = TimerGoingUp
    , typingReset = False
    }



-- UPDATE


type TimerState
    = TimerGoingUp
    | TimerGoingDown
    | TimerBridge Bool
    | TimerReset
    | TimerStop


type Msg
    = RandomTypingPace
    | NewTypingPace Float
    | ChangeTimerState TimerState
    | TypingTimeAdd
    | TypingTimeSub


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomTypingPace ->
            ( model, Random.generate NewTypingPace (Random.float 1 3) )

        NewTypingPace t ->
            ( { model | typingRandomPace = t }, Cmd.none )

        ChangeTimerState ts ->
            let
                checkIfListOfTitlesIsFull =
                    model.titleIndex >= List.length model.titleList - 1 && model.typingReset == False

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
                Time.every (60 * eraserPace) (\_ -> TypingTimeSub)

            TimerReset ->
                Sub.none

            TimerStop ->
                Sub.none
        ]



-- VIEW


getTitle : Model -> Int -> String
getTitle model index =
    Array.fromList model.titleList
        |> Array.get index
        |> Maybe.withDefault "Hi, I am a robot!"


getTitleCharAmount : Model -> Int
getTitleCharAmount model =
    getTitle model model.titleIndex
        |> String.length


slicer : Model -> Int -> Int -> String
slicer model index typing =
    getTitle model index
        |> String.slice 0 typing



-- Typing Component


tc : Model -> (List (Attribute Msg) -> List (Html Msg) -> Html Msg) -> Html Msg
tc model component =
    component
        [ ariaLabel <| getTitle model model.titleIndex
        , onClick <| ChangeTimerState TimerReset
        , style "cursor-pointer" "pointer"
        ]
        [ text <| slicer model model.titleIndex model.typingTimeChar ]
