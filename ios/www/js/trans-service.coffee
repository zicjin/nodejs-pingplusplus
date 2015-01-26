bumblebee.service 'TransService', ($rootScope, $http)->
    transes = []
    current_index = 0
    service =
        init: (user_id, callback)->
            $http.get(glo_domain + "trans/user/#{user_id}/#{transes.length}").success (data)->
                _.each data, (el)-> transes.push el
                service.setCurrent current_index if transes.length
                callback()
        getAll: -> transes
        get: (trans_id)->
            _.findWhere transes, {id: trans_id}
        getCurrent: ->
            transes[current_index] if transes.length
        getCurrentIndex: ->
            current_index
        setCurrent: (index)->
            current_index = index
            transes.forEach (el)-> el.current = false
            transes[index].current = true
            transes[index].alert = false
            $rootScope.$broadcast('trans.update')
        add: (trans)->
            trans.alert = true
            transes.unshift trans
            $rootScope.$broadcast('trans.added')
        upadte: (trans)->
            trans.alert = true
            _trans = _.findWhere transes, { id: trans.id }
            if _trans
                # index = _.indexOf transes, _trans
                if _trans.current then trans.current = true
                _trans = trans
                $rootScope.$broadcast('trans.updated')
            return

    return service