#
# Action Controller
#
# Triggers mouse and keyboard actions based on configured recipes. Actions are idempotent operations.
#
robot   = require 'robotjs'
execSh  = require 'exec-sh'


class ActionController
    constructor: (@action) ->
        console.log 'constructor) '

    runKeyboardAction: (keys) =>
        console.log 'keys ' + keys.toString()
        #press keys
        for key in keys
            robot.keyToggle(key, 'down')

        #release keys
        for key in keys by -1
            robot.keyToggle(key, 'up')

    run: () =>
        console.log 'run!!!!!!!!!!!!!!!!'
        switch @action.type
            when "keyboard"
                console.log 'fdsfdsf ' + @action.keys.toString()
                @runKeyboardAction @action.keys
# execute action, execute tear down action, set action state active/inactive.. fuuuu
#
window.ActionController = ActionController
