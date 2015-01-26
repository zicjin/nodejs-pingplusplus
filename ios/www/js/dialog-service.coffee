bumblebee.service 'DialogService', ($rootScope, $http, $localstorage, $q, SignalrService)->
    # dialogs = $localstorage.getArray 'dialogs', [] # annotation for debug
    dialogs = []
    types_entitys = {}
    service =
        pullData: (callback)->
            user = $localstorage.getObject 'user'
            if not user.id then return
            $http.get(glo_domain + "dialogs/#{user.id}/#{dialogs.length}").success (data)->
                data.forEach (el)->
                    service.parseProperty el
                    dialogs.push el
                $localstorage.setObject 'dialogs', dialogs
                callback() if callback
        getAll: -> dialogs
        get: (index)-> dialogs[index]
        get_reverse: (index)-> dialogs[dialogs.length-1-index]
        add: (dialog)->
            service.parseProperty dialog
            dialogs.unshift dialog
            $rootScope.$broadcast('dialog.added')
            return
        replace: (old_dialog, new_dialog)->
            dialog = _.findWhere dialogs, {createTime: old_dialog.createTime}
            index = _.indexOf dialogs, dialog # can not indexOf old_dialog http://stackoverflow.com/a/23656919/346701
            if index isnt -1
                service.parseProperty new_dialog
                dialogs[index] = new_dialog
                $rootScope.$broadcast('dialog.replaced')
            return
        clear: ->
            dialogs = []
        injectTypeData: ()->
            types_entitys = {}
            deferred = $q.defer()
            $http.get(glo_domain + "dialogs/types").success (data)->
                types_entitys = data
                deferred.resolve data
            deferred.promise
        parseProperty: (entity)->
            if entity.type is 4
                entity.trans = JSON.parse entity.content
                if not entity.selectChoiceValue then return
                switch entity.trans.type
                    when 2
                        entity.service_entity = _.findWhere types_entitys.express_services, {value: entity.service}
                    when 3
                        entity.service_entity = _.findWhere types_entitys.cleaning_services, {value: entity.service}

        # Help Signalr Func
        registerSignalr: ->
            SignalrService.on 'addDialog', (dialog)->
                service.add dialog
            SignalrService.on 'replaceDialog', (old_dialog, dialog)->
                service.replace old_dialog, dialog
        postToSignalr: (dialog)->
            user = $localstorage.getObject 'user'
            dialog.userId = user.id
            dialog.managerId = user.managerId
            dialog.senderName = user.nickname
            SignalrService.invoke 'addDialog', dialog
        replaceSingleChoicesDialogToSignalr: (dialog)->
            old_dialog = _.clone dialog
            old_dialog.selectChoiceValue = 0
            SignalrService.invoke 'replaceDialog', old_dialog, dialog
        replaceMultiChoicesDialogToSignalr: (dialog)->
            old_dialog = _.clone dialog
            old_dialog.choices.forEach (item)-> item.selected = false
            SignalrService.invoke 'replaceDialog', old_dialog, dialog
        replaceCardDialogToSignalr: (dialog)->
            old_dialog = _.clone dialog
            old_dialog.selectChoiceValue = 0 #uncheck
            SignalrService.invoke 'replaceDialog', old_dialog, dialog
    return service