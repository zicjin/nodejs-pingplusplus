// Generated by CoffeeScript 1.8.0
bumblebee.directive('transCard', function(DialogService) {
  return {
    restrict: 'E',
    template: '<ng-include src="templateUrl"/>',
    link: function(scope, elem, attrs) {
      scope.templateUrl = "templates/trans/" + (attrs.transType.toLowerCase()) + "_card.html";
      scope.dialog = DialogService.get_reverse(attrs.dialogIndex);
      scope.$on('dialog.replaced', function() {
        return scope.dialog = DialogService.get_reverse(parseInt(attrs.dialogIndex));
      });
      scope.ok = function(dialog) {
        var onDeviceReady, trans_ids;
        trans_ids = dialog.trans.type + "T" + dialog.trans.id;
                    cordova.exec(function(winParam) {alert(winParam);},
                                 function(error){alert("Error: \r\n");},
                                 "pay","functionInOc",
                                 [trans_ids]);
      };
      return scope.cancel = function(dialog) {
        scope.dialog.selectChoiceValue = 2;
        return DialogService.replaceCardDialogToSignalr(scope.dialog);
      };
    }
  };
});
