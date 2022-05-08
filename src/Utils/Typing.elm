module Utils.Typing exposing
    ( Model
    , Msg(..)
    , init
    , subs
    , tc
    , update
    )

import Array
import Html exposing (Attribute, Html, text)
import Html.Attributes exposing (style)
import Html.Attributes.Aria exposing (ariaLabel)
import Html.Events exposing (onClick)
import Random
import Time
import Utils.TaskBase exposing (run)



-- INIT


type alias Model =
    { stringList : List String
    , stringIndex : Int
    , typingWritingTime : Int
    , typingWritingPace : Float
    , typingWritingState : TypingState
    , resetTypingProcess : Bool
    }


init : Model
init =
    { stringList = [ "Change This String To Anything" ]
    , stringIndex = 0
    , typingWritingTime = 0
    , typingWritingPace = 10
    , typingWritingState = GoingUp
    , resetTypingProcess = False
    }



-- UPDATE


type TypingState
    = GoingUp
    | GoingDown
    | Bridge Bool
    | Reset
    | Stop


type Msg
    = TypingMore
    | TypingLess
    | TypingWritingPace
    | NewTypingWritingPace Float
    | ChangeWritingState TypingState


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TypingMore ->
            let
                typingMore =
                    model.typingWritingTime + 1
            in
            if model.typingWritingTime < getCharAmount model - 1 then
                ( { model | typingWritingTime = typingMore }
                , Cmd.none
                )

            else if model.typingWritingTime < getCharAmount model then
                ( { model | typingWritingTime = typingMore }
                , run <| ChangeWritingState model.typingWritingState
                )

            else
                ( model
                , run <| ChangeWritingState model.typingWritingState
                )

        TypingLess ->
            if model.typingWritingTime > 0 then
                ( { model
                    | typingWritingTime =
                        model.typingWritingTime - 1
                  }
                , Cmd.none
                )

            else
                ( model
                , run <| ChangeWritingState model.typingWritingState
                )

        TypingWritingPace ->
            let
                mostFast =
                    1

                mostSlow =
                    3
            in
            ( model
            , Random.float mostFast mostSlow
                |> Random.generate NewTypingWritingPace
            )

        NewTypingWritingPace t ->
            ( { model | typingWritingPace = t }, Cmd.none )

        ChangeWritingState ts ->
            let
                checkIfListOfTitlesIsFull =
                    model.stringIndex
                        >= List.length model.stringList
                        - 1
                        && model.resetTypingProcess
                        == False

                stopTyping timingState =
                    if checkIfListOfTitlesIsFull then
                        Stop

                    else
                        timingState
            in
            case ts of
                GoingUp ->
                    ( { model
                        | typingWritingState =
                            stopTyping GoingDown
                      }
                    , Cmd.none
                    )

                GoingDown ->
                    ( { model
                        | typingWritingState =
                            Bridge model.resetTypingProcess
                      }
                    , Cmd.none
                    )

                Bridge reset ->
                    let
                        timeReset =
                            if reset then
                                0

                            else
                                model.stringIndex + 1
                    in
                    ( { model
                        | typingWritingState = stopTyping GoingUp
                        , stringIndex = timeReset
                        , resetTypingProcess = False
                      }
                    , Cmd.none
                    )

                Reset ->
                    ( { model
                        | typingWritingState = Bridge True
                        , resetTypingProcess = True
                      }
                    , Cmd.none
                    )

                Stop ->
                    ( model, Cmd.none )



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    let
        eraserPace =
            if model.typingWritingTime < 3 then
                4

            else if model.typingWritingTime == getCharAmount model then
                8

            else
                1
    in
    Sub.batch
        [ case model.typingWritingState of
            GoingUp ->
                Sub.batch
                    [ Time.every (60 * model.typingWritingPace) (\_ -> TypingMore)
                    , Time.every (60 * 10) (\_ -> TypingWritingPace)
                    ]

            GoingDown ->
                Time.every (60 * eraserPace) (\_ -> TypingLess)

            Bridge _ ->
                Time.every (60 * eraserPace) (\_ -> TypingLess)

            Reset ->
                Sub.none

            Stop ->
                Sub.none
        ]



-- VIEW


getStringByIndex : Model -> Int -> String
getStringByIndex model index =
    Array.fromList model.stringList
        |> Array.get index
        |> Maybe.withDefault "Hi, I am a incompetent robot!"


getCharAmount : Model -> Int
getCharAmount model =
    getStringByIndex model model.stringIndex
        |> String.length


slicer : Model -> Int -> Int -> String
slicer model index typing =
    getStringByIndex model index
        |> String.slice 0 typing



-- Typing Component


tc :
    Model
    -> (List (Attribute Msg) -> List (Html Msg) -> Html Msg)
    -> Attribute Msg
    -> Html Msg
tc model htmlElement attr =
    htmlElement
        [ attr
        , ariaLabel <| getStringByIndex model model.stringIndex
        , onClick <| ChangeWritingState Reset
        , style "cursor-pointer" "pointer"
        ]
        [ text <|
            slicer model
                model.stringIndex
                model.typingWritingTime
        ]
