module Pages.Home_ exposing (Model, Msg, page, subs)

import Browser.Dom as BrowserDom exposing (Element, Error)
import Gen.Params.Home_ exposing (Params)
import Gen.Route as Route
import Html exposing (Html, h1, section)
import Html.Attributes exposing (class)
import Layout exposing (headerClass, pageConfig)
import Page
import Request
import Shared
import Task
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
    = GotHeader (Result Error Element)
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
                ]
            , mainContent = [ viewIntro model ]
        }


introStringList : List String
introStringList =
    [ "Hi, I'm Johann"
    , "I'm a software developer"
    , "I work at the web"
    , "I Love Code, UI and Design"
    , "So let's work together"
    ]


viewIntro : Model -> Html Msg
viewIntro model =
    section [ class "intro" ]
        [ class "intro__title"
            |> Typing.tc model.typingModel h1
            |> Html.map TypingMsg
        ]
