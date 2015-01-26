bumblebee.directive 'transCard', (DialogService)->
    restrict: 'E'
    template: '<ng-include src="templateUrl"/>'
    link: (scope, elem, attrs)->
        scope.templateUrl = "templates/trans/#{attrs.transType.toLowerCase()}_card.html"
        scope.dialog = DialogService.get_reverse attrs.dialogIndex
        scope.$on 'dialog.replaced', ->
            scope.dialog = DialogService.get_reverse parseInt attrs.dialogIndex
        scope.ok = (dialog)->
            trans_ids = dialog.trans.type + "_" + dialog.trans.id
            onDeviceReady = ->
                cordova.exec ((winParam) ->
                    alert winParam
                    return
                ), ((error) ->
                    alert "Error: \r\n"
                    return
                ), "MyPlugin", "functionInOc", [trans_ids]
                return
            # scope.dialog.selectChoiceValue = 1 #ok
            # DialogService.replaceCardDialogToSignalr scope.dialog
        scope.cancel = (dialog)->
            scope.dialog.selectChoiceValue = 2 #cancel
            DialogService.replaceCardDialogToSignalr scope.dialog

# http://stackoverflow.com/a/21835866/346701