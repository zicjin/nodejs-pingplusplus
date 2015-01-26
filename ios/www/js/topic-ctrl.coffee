bumblebee.controller "TransesCtrl", ($scope, $stateParams, TransService) ->
    $scope.transes = TransService.getAll()
    return

bumblebee.controller "TransCtrl", ($scope, $stateParams, transaction, $TransService) ->
    $scope.trans = transaction
    $scope.hide_navicon = true
    # $ionicNavBarDelegate.setTitle "asdasd"

    return
    # messageQueue = []

    # $scope.add = ->
    #     nextMessage = messageQueue[messageIter++ % messageQueue.length]
    #     $scope.messages.push angular.extend({}, nextMessage)

    #     $ionicScrollDelegate.resize()
    #     $timeout ->
    #         $ionicScrollDelegate.scrollBottom true
    #     , 1