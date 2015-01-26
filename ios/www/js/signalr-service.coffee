bumblebee.service 'SignalrService', ($rootScope, $localstorage, $timeout)->
    # http://goo.gl/zuYomn
    connection = $.hubConnection()
    connection.url = glo_hub_domain + 'signalr'
    hub_proxy = {}
    # http://goo.gl/LH3JAc
    connection.reconnected ->
        $.notify "已链接", "success"
    connection.disconnected ->
        $.notify "链接丢失!", "error"
        $timeout ->
            connection.start()
        , 2000

    service =
        init: ->
            user = $localstorage.getObject 'user'
            if not user.id then return
            service.stop()
            connection.qs =
                role : 'user'
                identity: user.id
            hub_proxy = connection.createHubProxy 'bumblebeeHub'
        start: (callback)->
            connection.start().done callback
            .fail (err)->
                $.notify "signalr connect fail:" + err, "error"
                return
        stop: ->
            connection.stop()
            hub_proxy = {}
        on: (eventName, callback)->
            if not hub_proxy.on then return
            hub_proxy.off eventName
            hub_proxy.on eventName, ->
                _args = arguments
                if callback
                    $rootScope.$apply -> callback.apply callback, _args
                    # callback _args # is fail!
        off: (eventName, callback)->
            hub_proxy.off eventName, ->
                _args = arguments
                if callback
                    $rootScope.$apply -> callback.apply callback, _args
        invoke: ->
            if not hub_proxy then return
            len = arguments.length
            _args = Array.prototype.slice.call arguments
            hub_proxy.invoke.apply hub_proxy, _args
            .done (result)->
                if _.isFunction _args[len-1]
                    callback = _args.pop()
                    $rootScope.$apply -> callback result
            return
        hub: -> hub_proxy

    service.init()
    $rootScope.$on 'logined', -> service.init()

    return service