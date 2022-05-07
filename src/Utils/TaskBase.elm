module Utils.TaskBase exposing (run)

import Task exposing (perform, succeed)


run : msg -> Cmd msg
run m =
    perform (always m) (succeed ())
