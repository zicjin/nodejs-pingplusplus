bumblebee.controller "HomeCtrl", ($scope, $rootScope, $localstorage, $ionicModal, $http, $ionicScrollDelegate, $timeout, SignalrService, DialogService) ->
    user = $localstorage.getObject 'user'
    # todo: htmlSafe: http://stackoverflow.com/a/19417443/346701
    scrollBottom = ->
        $ionicScrollDelegate.resize()
        $timeout ->
            $ionicScrollDelegate.scrollBottom true
        , 1

    ol_msg = $("ol.messages")
    lazyGetDialog = _.debounce ->
        if ol_msg.scrollTop() is 0
            DialogService.getDialog()
    , 300
    ol_msg.scroll lazyGetDialog

    DialogService.registerSignalr()
    SignalrService.start()
    $('#subInput').on "keyup", (e)->
        if e.keyCode isnt 13 then return
        if not $scope.subText then return
        DialogService.postToSignalr
            type: 0 #UserText
            content: $scope.subText
        $scope.subText = ""

    $scope.change_single_choices = (dialog)->
        DialogService.replaceSingleChoicesDialogToSignalr dialog

    $scope.change_multi_choices = (dialog)->
        DialogService.replaceMultiChoicesDialogToSignalr dialog

    $scope.$on 'dialog.added', scrollBottom
    $scope.$on 'dialog.addByReplaced', scrollBottom
    $scope.$on 'dialog.replaced', scrollBottom

    constructor = ->
        promise = DialogService.injectTypeData()
        promise.then (data)->
            DialogService.clear()
            DialogService.pullData ->
                $scope.dialogs = DialogService.getAll()
                scrollBottom()
    $rootScope.$on 'logined', constructor
    constructor()

    path_box = $("#path-box")
    text_box = $("#text-box")
    $scope.switch_voice = ->
        path_box.toggleClass('up').toggleClass 'down', !path_box.hasClass('up')
        text_box.toggle !path_box.hasClass('up')
        return
    $scope.switch_voice()

    voice_btn = $('#voice-btn')
    box_width = voice_btn.parent(".path-item").width()
    voice_aperture = $("#voice-aperture")
    $scope.start_voice = ->
        if not navigator.speech then return
        navigator.speech.cancelListening()
        voice_btn.addClass "listening"
        time_promise = $timeout ->
            voice_btn.removeClass "listening"
        , 10000
        navigator.speech.startListening
            language:'zh_cn'
            accent:'mandarin'
        , (str)->
            voice_btn.removeClass "listening"
            DialogService.postToSignalr
                type: 0 #UserText
                content: str
            $timeout.cancel time_promise
            return

        voice_aperture.animate(
            height: box_width
            width: box_width
        , 150).animate
            height: 68
            width: 68
        , 150
        return

    voice_throttled = _.throttle (val)->
        voice_aperture.animate
            height: val
            width: val
        , 150
    , 150
    if navigator.speech
        navigator.speech.addEventListener "VolumeChanged", (obj)->
            val = parseInt(obj.volume)*8
            if val > box_width then val = box_width else if val < 68 then val = 68
            voice_throttled val+"px"

    $http.get('help_list.json').success (data)->
        $scope.help_list = data

    $ionicModal.fromTemplateUrl 'templates/help-modal.html',
        scope: $scope,
        animation: 'slide-in-up'
    .then (modal)->
        $scope.help_modal = modal

    $scope.switch_help = ->
        $scope.help_modal.show()

    $scope.close_help = ->
        $scope.help_modal.hide()

    $scope.$on "$destory", ->
        $scope.help_modal.remove()
        $('#subInput').off "keyup"
        SignalrService.stop()

    return

bumblebee.filter 'reverse', ->
    (items)->
        items.slice().reverse() if items

bumblebee.filter 'display_dialog', ->
    (items)->
        if items
            items.forEach (dialog)->
                if dialog.trans
                    dialog.trans.displayTime = moment(dialog.trans.time).format('MMM DD, hh:mm') if dialog.trans.time
        items