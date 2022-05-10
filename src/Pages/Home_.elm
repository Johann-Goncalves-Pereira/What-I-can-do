module Pages.Home_ exposing (Model, Msg, page, subs)

import Array exposing (Array)
import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Attribute, Html, div, h1, p, section, span, text)
import Html.Attributes exposing (attribute, class, classList, id)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html.Events.Extra.Mouse as Mouse
import Layout exposing (headerClass, pageConfig)
import Page
import Process
import Request
import Round
import Shared
import Task
import Utils.Cursor as Cursor
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
    { -- Size
      headerSize : Int
    , cursorSize : { w : Float, h : Float }

    -- Model
    , cursorModel : Cursor.Model
    , typingModel : Typing.Model

    -- UI
    , cursorUI :
        { className : String
        , content : Maybe (List (Html Msg))
        }
    }


init : ( Model, Cmd Msg )
init =
    ( { -- Size
        headerSize = 18
      , cursorSize = { w = 48, h = 48 }

      -- Init
      , cursorModel = Cursor.init
      , typingModel = Typing.init

      -- UI
      , cursorUI = { className = "", content = Nothing }
      }
    , Cmd.batch
        [ BrowserDom.getElement headerClass
            |> Task.attempt GotHeader
        , getCursorSize
        ]
    )



-- UPDATE


type CursorUI
    = Normal
    | MixSolid
    | Clickable


type Msg
    = -- Size
      GotHeader (Result Error Element)
    | GotCursor (Result Error Element)
      -- Msg
    | CursorMsg Cursor.Msg
    | TypingMsg Typing.Msg
      -- UI
    | CursorUI CursorUI


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotHeader promiseResponse ->
            case promiseResponse of
                Err _ ->
                    ( model, Cmd.none )

                Ok element ->
                    ( { model
                        | headerSize =
                            round element.element.height
                      }
                    , Cmd.none
                    )

        GotCursor promiseResponse ->
            case promiseResponse of
                Err _ ->
                    ( model, Cmd.none )

                Ok element ->
                    ( { model
                        | cursorSize =
                            { w = element.element.width
                            , h = element.element.height
                            }
                      }
                    , Cmd.none
                    )

        CursorMsg cursorMsg ->
            ( { model
                | cursorModel =
                    Cursor.update cursorMsg model.cursorModel
              }
            , Cmd.none
            )

        TypingMsg typingMsg ->
            let
                ( typingModel, typingCmd ) =
                    Typing.update typingMsg model.typingModel
            in
            ( { model
                | typingModel =
                    { typingModel
                        | stringList = introStringList
                    }
              }
            , Cmd.map TypingMsg typingCmd
            )

        CursorUI ui ->
            let
                mc =
                    model.cursorUI
            in
            case ui of
                Normal ->
                    ( { model
                        | cursorUI =
                            { mc | className = "", content = Nothing }
                      }
                    , getCursorSize
                    )

                MixSolid ->
                    ( { model
                        | cursorUI =
                            { mc | className = "--mix", content = Nothing }
                      }
                    , getCursorSize
                    )

                Clickable ->
                    ( { model
                        | cursorUI =
                            { mc | className = "--clickable", content = Just <| cursorContent 0 }
                      }
                    , getCursorSize
                    )


getCursorSize : Cmd Msg
getCursorSize =
    BrowserDom.getElement cursorId
        |> Task.attempt GotCursor



-- SUBSCRIBE


subs : Model -> Sub Msg
subs model =
    model.typingModel
        |> Typing.subs
        |> Sub.map TypingMsg



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
            , rootContent = { before = [ cursor model ], after = [] }
            , rootAttrs =
                [ -- Cursor
                  Mouse.onMove (.clientPos >> Cursor.ClientMovement)
                , onMouseEnter Cursor.CursorShow
                , onMouseLeave Cursor.CursorHide
                ]
                    |> List.map (Html.Attributes.map CursorMsg)
            , linkAttrs =
                [ onMouseEnter <| CursorUI MixSolid
                , onMouseLeave <| CursorUI Normal
                ]
            , mainAttrs =
                [ customProps
                    [ { prop = "header-height"
                      , value = String.fromInt model.headerSize ++ "px"
                      }
                    ]
                ]
            , mainContent = mainContentList model
        }


cursor : Model -> Html Msg
cursor model =
    let
        cv :
            { x : Float
            , y : Float
            , w : Float
            , h : Float
            }
        cv =
            -- Cursor Value
            { x = model.cursorModel.mouseClientPosition.x
            , y = model.cursorModel.mouseClientPosition.y
            , w = model.cursorSize.w
            , h = model.cursorSize.h
            }

        transformPosition : Attribute msg
        transformPosition =
            String.concat
                [ "transform:"
                , "translate(clamp(0px,"
                , Round.round 0 (cv.x - cv.w / 2)
                , "px,100vw - 100% - 2px),"
                , "clamp(0px,"
                , Round.round 0 (cv.y - cv.h / 2)
                , "px,100vh - 100% - 2px));"
                ]
                |> attribute "style"
    in
    if model.cursorModel.mouseCursorShow then
        div
            [ classList
                [ ( cursorId, True )
                , ( cursorId ++ model.cursorUI.className, True )
                ]
            , id cursorId
            , transformPosition
            ]
            [ div
                [ classList
                    [ ( cursorId ++ "__ui", True )
                    , ( cursorId ++ "__ui" ++ model.cursorUI.className, True )
                    ]
                ]
                (case model.cursorUI.content of
                    Nothing ->
                        []

                    Just content ->
                        content
                )
            ]

    else
        text ""


cursorId : String
cursorId =
    "cursor"


cursorContent : Int -> List (Html Msg)
cursorContent index =
    [ [ span [ class "click" ] [ text "Click me" ] ]
    ]
        |> Array.fromList
        |> Array.get index
        |> Maybe.withDefault []


mainContentList : Model -> List (Html Msg)
mainContentList model =
    [ viewIntro model ]


viewIntro : Model -> Html Msg
viewIntro model =
    section [ class "intro" ]
        [ div
            [ class "intro__title-wrapper"
            , onMouseEnter (CursorUI Clickable)
            , onMouseLeave (CursorUI Normal)
            ]
            [ class "intro__title"
                |> Typing.tc model.typingModel h1
                |> Html.map TypingMsg
            ]
        ]


introStringList : List String
introStringList =
    [ "Hi, I'm Johann"
    , "I'm a software developer"
    , "I work at the web"
    , "I Love Code, UI and Design"
    , "So let's work together"
    ]
