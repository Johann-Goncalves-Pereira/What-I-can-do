module Layout exposing (Model, headerClass, layout, pageConfig)

import Array
import Gen.Route as Route exposing (Route)
import Html exposing (Attribute, Html, a, div, header, li, main_, nav, text, ul)
import Html.Attributes exposing (class, classList, href, id, tabindex)
import Regex



-- INIT


type alias Model msg =
    { -- Routing
      route : Route

    -- Root
    , rootContent :
        { before : List (Html msg)
        , after : List (Html msg)
        }
    , rootAttrs : List (Attribute msg)

    -- Header
    , headerContent : List (Html msg)
    , headerAttrs : List (Attribute msg)
    , linkAttrs : List (Attribute msg)

    -- Main
    , mainContent : List (Html msg)
    , mainAttrs : List (Attribute msg)
    }


type alias Link =
    { routeStatic : Route
    , routeReceived : Route
    , routeName : String
    }


pageConfig : Model msg
pageConfig =
    { -- Routing
      route = Route.Home_

    -- Root
    , rootContent = { before = [], after = [] }
    , rootAttrs = []

    -- Header
    , headerContent = []
    , headerAttrs = []
    , linkAttrs = []

    -- Main
    , mainContent = []
    , mainAttrs = []
    }


defaultLink : Link
defaultLink =
    { routeStatic = Route.Home_
    , routeReceived = Route.Home_
    , routeName = ""
    }



-- ROUTING


isRoute : Route -> Route -> Bool
isRoute route compare =
    case ( route, compare ) of
        ( Route.Home_, Route.Home_ ) ->
            True

        _ ->
            False


caseNamePage : Route -> String
caseNamePage route =
    case route of
        Route.Home_ ->
            "Home"

        Route.NotFound ->
            "Not Found"


userReplace : String -> (Regex.Match -> String) -> String -> String
userReplace userRegex replacer string =
    case Regex.fromString userRegex of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string


classBuilder : String -> String
classBuilder string =
    userReplace "[ ]" (\_ -> "-") string
        |> String.toLower



-- VIEW


layout : Model msg -> List (Html msg)
layout model =
    let
        mainClass : Attribute msg
        mainClass =
            class <| "main--" ++ classBuilder (caseNamePage model.route)
    in
    [ div
        ([ id "root"
         , classList
            [ ( "root", True )
            , ( "scroll", True )
            , ( String.concat
                    [ "root--"
                    , caseNamePage model.route
                        |> classBuilder
                    ]
              , True
              )
            ]
         ]
            ++ model.rootAttrs
        )
        (model.rootContent.before
            ++ [ viewHeader model
               , main_ (mainClass :: model.mainAttrs) model.mainContent
               ]
            ++ model.rootContent.after
        )
    ]


headerClass : String
headerClass =
    "root__header"


viewHeader : Model msg -> Html msg
viewHeader model =
    header ([ class headerClass, id headerClass ] ++ model.headerAttrs)
        (model.headerContent
            ++ [ nav [ class <| headerClass ++ "__nav" ]
                    [ ul [ class <| headerClass ++ "__ul" ] <|
                        viewHeaderLinks model [ Route.Home_ ]
                    ]
               ]
        )


viewHeaderLinks : Model msg -> List Route -> List (Html msg)
viewHeaderLinks model links =
    List.map
        (\staticRoute ->
            viewLink model
                { defaultLink
                    | routeName = caseNamePage staticRoute
                    , routeStatic = staticRoute
                    , routeReceived = model.route
                }
        )
        links


viewLink : Model msg -> Link -> Html msg
viewLink model link =
    let
        linkClass : String
        linkClass =
            headerClass ++ "__link"
    in
    li [ class <| headerClass ++ "__item" ]
        [ a
            ([ class linkClass
             , classList
                [ ( linkClass ++ "--current-page"
                  , isRoute link.routeReceived link.routeStatic
                  )
                ]
             , href <| Route.toHref link.routeStatic
             , tabindex 1
             ]
                ++ model.linkAttrs
            )
            [ text link.routeName ]
        ]
