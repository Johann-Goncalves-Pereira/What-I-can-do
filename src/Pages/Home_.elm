module Pages.Home_ exposing (Model, Msg, page, subs)

import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Attribute, Html, h1, section, text)
import Html.Attributes exposing (class, id)
import Html.Events.Extra.Mouse as Mouse
import Layout exposing (headerClass, pageConfig)
import Page
import Request
import Round
import Shared
import Task
import Utils.Cursor as Cursor exposing (cursor)
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
    { headerSize : Int
    , cursorSize : { w : Float, h : Float }
    , cursorModel : Cursor.Model
    , typingModel : Typing.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { headerSize = 18
      , cursorSize = { w = 48, h = 48 }
      , cursorModel = Cursor.init
      , typingModel = Typing.init
      }
    , Cmd.batch
        [ BrowserDom.getElement headerClass
            |> Task.attempt GotHeader
        , BrowserDom.getElement cursorId
            |> Task.attempt GotCursor
        ]
    )



-- UPDATE


type Msg
    = GotHeader (Result Error Element)
    | GotCursor (Result Error Element)
    | CursorMsg Cursor.Msg
    | TypingMsg Typing.Msg


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
            , mainAttrs =
                [ customProps
                    [ { prop = "header-height"
                      , value = String.fromInt model.headerSize ++ "px"
                      }
                    ]
                , Mouse.onMove (.clientPos >> Cursor.ClientMovement)
                    |> Html.Attributes.map CursorMsg
                ]
            , mainContent = mainContentList model
        }


mainContentList : Model -> List (Html Msg)
mainContentList model =
    let
        cursorValue :
            { x : Float
            , y : Float
            , w : Float
            , h : Float
            }
        cursorValue =
            { x = model.cursorModel.mouseClientPosition.x
            , y = model.cursorModel.mouseClientPosition.y
            , w = model.cursorSize.w
            , h = model.cursorSize.h
            }
    in
    [ cursor
        [ class "cursor"
        , id cursorId
        , customProps
            [ { prop = "cursor-pos-x"
              , value =
                    Round.round 2 (cursorValue.x - cursorValue.w / 2) ++ "px"
              }
            , { prop = "cursor-pos-y"
              , value =
                    Round.round 2 (cursorValue.y - cursorValue.h / 2) ++ "px"
              }
            ]
        ]
        Nothing
        |> Html.map CursorMsg
    , viewIntro model
    ]


cursorId : String
cursorId =
    "cursor"


viewIntro : Model -> Html Msg
viewIntro model =
    section [ class "intro" ]
        [ class "intro__title"
            |> Typing.tc model.typingModel h1
            |> Html.map TypingMsg
        ]


introStringList : List String
introStringList =
    [ "Hi, I'm Johann"
    , "I'm a software developer"
    , "I work at the web"
    , "I Love Code, UI and Design"
    , "So let's work together"
    ]
