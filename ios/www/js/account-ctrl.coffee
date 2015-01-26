bumblebee.controller "MeCtrl", ($scope, $ionicModal, $http, $localstorage, $location) ->
  $scope.loginOut = ->
    $localstorage.setObject 'user', {}
    $scope.user = $localstorage.getObject 'user', {}
    $location.path("/login")

bumblebee.controller "ChangePasswordCtrl", ($scope, $ionicNavBarDelegate, $http, $localstorage, $rootScope) ->
  $scope.formData = {}
  user = $localstorage.getObject 'user', {}

  $scope.submit = ->
    $http.put glo_domain+"users/password",
      Id: user.id
      oldPassword: $scope.formData.oldPassword
      newPassword: $scope.formData.newPassword
    .success (user)->
      $localstorage.setObject 'user', user
      $rootScope.$broadcast('logined')
      $ionicNavBarDelegate.back()
    return

bumblebee.controller "ChangeNickNameCtrl", ($scope, $ionicNavBarDelegate, $http, $localstorage, $rootScope) ->
  $scope.formData = {}
  user = $localstorage.getObject 'user', {}

  $scope.submit = ->
    $http.put glo_domain+"users/password",
      Id: user.id
      oldPassword: $scope.formData.oldPassword
      newPassword: $scope.formData.newPassword
    .success (user)->
      $localstorage.setObject 'user', user
      $rootScope.$broadcast('logined')
      $ionicNavBarDelegate.back()
    return


bumblebee.controller "ChangePhoneCtrl", ($scope, $ionicNavBarDelegate, $http, $localstorage, $rootScope) ->
  $scope.formData = {}
  user = $localstorage.getObject 'user', {}

  $scope.submit = ->
    $http.put glo_domain+"users/password",
      Id: user.id
      oldPassword: $scope.formData.oldPassword
      newPassword: $scope.formData.newPassword
    .success (user)->
      $localstorage.setObject 'user', user
      $rootScope.$broadcast('logined')
      $ionicNavBarDelegate.back()
    return


bumblebee.controller "LoginCtrl", ($scope, $location, $http, $localstorage, $rootScope) ->
  $scope.loginData =
    password: "z5656z"
    phone: "18551090081"
  $scope.login = ->
    $http.post glo_domain+"users/session",
      Phone: $scope.loginData.phone
      Password: $scope.loginData.password
    .success (user)->
      $localstorage.setObject 'user', user
      $rootScope.$broadcast('logined')
      $location.path("/app/home")
    return

bumblebee.controller "RegisterCtrl", ($scope, $location, $http, $localstorage, $rootScope) ->
  $scope.registerData = {}
  $scope.registerStep = 1
  registerUser = {}
  $scope.registerPhone = ->
    $http.post glo_domain+"users/phone",
      Phone: $scope.registerData.phone
      Password: $scope.registerData.password
    .success (user)->
      registerUser = user
      AV.Cloud.requestSmsCode
        mobilePhoneNumber: user.phone,
        name: '神猪的注册',
        op: '手机验证',
        ttl: 5
      .then ->
        $scope.$apply -> $scope.registerStep = 2
      , (err)-> alert err+'。请联系管理员'
  $scope.registerSmsCode = ->
    AV.Cloud.verifySmsCode($scope.registerData.smscode).then ->
      $scope.$apply -> $scope.registerStep = 3
    , (err)-> alert "验证失败，请重试"
  $scope.register = ->
    $http.post glo_domain+"users/",
      Id: registerUser.id
      Nickname: $scope.registerData.nickname
      Gender: $scope.registerData.gender
    .success (user)->
      $localstorage.setObject 'user', user
      $rootScope.$broadcast('logined')
      $location.path("/")
