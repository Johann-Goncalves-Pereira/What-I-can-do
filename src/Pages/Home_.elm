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
    , cursorUI : CursorUI
    , cursorClass : String
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
      , cursorUI = CursorUINormal
      , cursorClass = ""
      }
    , Cmd.batch
        [ BrowserDom.getElement headerClass
            |> Task.attempt GotHeader
        , getCursorSize <| Just 5
        ]
    )



-- UPDATE


type CursorUI
    = CursorUINormal
    | CursorUIMixSolid
    | CursorUIClick


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
                    model.cursorClass
            in
            case ui of
                CursorUINormal ->
                    ( { model
                        | cursorClass = ""
                        , cursorUI = CursorUINormal
                      }
                    , getCursorSize <| Just 100
                    )

                CursorUIMixSolid ->
                    ( { model
                        | cursorClass = "--mix"
                        , cursorUI = CursorUIMixSolid
                      }
                    , getCursorSize <| Just 100
                    )

                CursorUIClick ->
                    ( { model
                        | cursorClass = "--click"
                        , cursorUI = CursorUIClick
                      }
                    , getCursorSize <| Just 100
                    )


getCursorSize : Maybe Float -> Cmd Msg
getCursorSize sleep =
    case sleep of
        Just time ->
            Process.sleep time
                |> Task.andThen (\_ -> BrowserDom.getElement cursorId)
                |> Task.attempt GotCursor

        Nothing ->
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
            , rootContent = { before = cursor model, after = [] }
            , rootAttrs =
                [ -- Cursor
                  Mouse.onMove (.clientPos >> Cursor.ClientMovement)
                , onMouseEnter Cursor.CursorShow

                -- , onMouseLeave Cursor.CursorHide
                ]
                    |> List.map (Html.Attributes.map CursorMsg)
            , linkAttrs =
                [ onMouseEnter <| CursorUI CursorUIMixSolid
                , onMouseLeave <| CursorUI CursorUINormal
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


cursor : Model -> List (Html Msg)
cursor model =
    let
        classes : { content : String, normal : String }
        classes =
            { content = "root__" ++ cursorId ++ "--content"
            , normal = "root__" ++ cursorId
            }

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

        transformPosition : Maybe String -> Attribute msg
        transformPosition more =
            String.concat
                [ "transform:"
                , "translate3d(clamp(0px,"
                , Round.round 0 (cv.x - cv.w / 2)
                , "px,100vw - 100% - 2px),"
                , "clamp(0px,"
                , Round.round 0 (cv.y - cv.h / 2)
                , "px,100vh - 100% - 2px)"
                , ", 0px) "
                , case more of
                    Just m ->
                        m

                    Nothing ->
                        String.join " "
                            [ "scale3d(1, 1, 1)"
                            , "rotateX(0deg)"
                            , "rotateY(0deg)"
                            , "rotateZ(0deg)"
                            , "skew(0deg, 0deg)"
                            ]
                ]
                |> attribute "style"

        cursorContent : Maybe String -> List (Html Msg) -> Html Msg
        cursorContent moreTransform content =
            div
                [ classList
                    [ ( classes.content, True )
                    , ( classes.content ++ model.cursorClass
                      , True
                      )
                    ]
                , transformPosition moreTransform
                ]
                content

        baseCursor : Maybe String -> Html Msg
        baseCursor moreTransform =
            div
                [ classList
                    [ ( classes.normal, True )
                    , ( classes.normal ++ model.cursorClass, True )
                    ]
                , id cursorId
                , transformPosition moreTransform
                ]
                []
    in
    if model.cursorModel.mouseCursorShow then
        case model.cursorUI of
            CursorUINormal ->
                [ baseCursor Nothing ]

            CursorUIMixSolid ->
                [ baseCursor Nothing ]

            CursorUIClick ->
                [ baseCursor Nothing
                , cursorContent Nothing
                    [ span [] [ text "Click Me" ] ]
                ]

    else
        []


cursorId : String
cursorId =
    "cursor"


mainContentList : Model -> List (Html Msg)
mainContentList model =
    [ viewIntro model ]


viewIntro : Model -> Html Msg
viewIntro model =
    section [ class "intro" ]
        [ div
            [ class "intro__title-wrapper"
            , onMouseEnter (CursorUI CursorUIClick)
            , onMouseLeave (CursorUI CursorUINormal)
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
