module Layout exposing (PageModel, layout, pageConfig)

import Array
import Gen.Route as Route exposing (Route)
import Html exposing (Attribute, Html, a, div, header, li, main_, nav, text, ul)
import Html.Attributes exposing (class, classList, href, id, tabindex)
import Regex



-- Model


type alias PageModel msg =
    { route : Route
    , mainContent : List (Html msg)
    , mainAttrs : List (Attribute msg)
    , extraPageComponent : Maybe (List (Html msg))
    }


type alias Link =
    { routeStatic : Route
    , routeReceived : Route
    , routeName : String
    }


pageConfig : PageModel msg
pageConfig =
    { route = Route.Home_
    , mainContent = []
    , mainAttrs = []
    , extraPageComponent = Nothing
    }


defaultLink : Link
defaultLink =
    { routeStatic = Route.Home_
    , routeReceived = Route.Home_
    , routeName = ""
    }



-- Structure


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



-- View


layout : PageModel msg -> List (Html msg)
layout model =
    let
        mainClass : Attribute msg
        mainClass =
            class <| "main--" ++ classBuilder (caseNamePage model.route)
    in
    [ [ viewHeader model
      , main_ (mainClass :: model.mainAttrs) model.mainContent
      ]
        ++ Maybe.withDefault [] model.extraPageComponent
        |> div
            [ id "root"
            , classList
                [ ( "scroll", True )
                , ( String.concat
                        [ "root--"
                        , classBuilder <| caseNamePage model.route
                        ]
                  , True
                  )
                ]
            ]
    ]


headerClass : String
headerClass =
    "root__header"


viewHeader : PageModel msg -> Html msg
viewHeader model =
    header [ class headerClass ]
        [ nav [ class <| headerClass ++ "__nav" ]
            [ ul [ class <| headerClass ++ "__ul" ] <|
                viewHeaderLinks model [ Route.Home_ ]
            ]
        ]


viewHeaderLinks : PageModel msg -> List Route -> List (Html msg)
viewHeaderLinks model links =
    List.map
        (\staticRoute ->
            viewLink
                { defaultLink
                    | routeName = caseNamePage staticRoute
                    , routeStatic = staticRoute
                    , routeReceived = model.route
                }
        )
        links


viewLink : Link -> Html msg
viewLink model =
    let
        linkClass : String
        linkClass =
            headerClass ++ "__link"
    in
    li [ class <| headerClass ++ "__item" ]
        [ a
            [ class linkClass
            , classList
                [ ( linkClass ++ "--current-page"
                  , isRoute model.routeReceived model.routeStatic
                  )
                ]
            , href <| Route.toHref model.routeStatic
            , tabindex 1
            ]
            [ text model.routeName ]
        ]
