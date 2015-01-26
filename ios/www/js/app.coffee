glo_debug = false
glo_domain = if glo_debug then "http://localhost:53696/" else "http://182.254.216.91:108/"
glo_hub_domain = if glo_debug then "http://localhost:53075/" else "http://182.254.216.91:2352/"
glo_version = "1"
# $ = (query) -> angular.element(document.querySelector(query))

bumblebee = angular.module("bumblebee", ["ionic"]).run ($ionicPlatform) -> #, 'ionic.utils'
  $ionicPlatform.ready ->
    # Hide the accessory bar by default
    # remove this to show the accessory bar above the keyboard for form inputs
    if window.cordova and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true
      cordova.plugins.Keyboard.disableScroll true
    # org.apache.cordova.statusbar required
    StatusBar.styleDefault() if window.StatusBar

    # navigator.speech.onSpeak (str)->
    #   $('textarea#read').val str
    #   $('div#status').html str

    # s = navigator.speech.voice_names
    # for v in s
    #   $('select#voice_name').append(new Option(s[v],v))

    return

  AV.initialize "5pr5he11yp8lxamdcap4g74kqzmv50cgmw44ovfh3evj7l75", "qzeqav2znb1vbch637lurxzgs7uefk5gndkrxjf0cp48u258"
  return

bumblebee.factory "$localstorage", ["$window", ($window) ->
  return (
    set: (key, value) ->
      $window.localStorage[key] = value
      return
    get: (key, defaultValue) ->
      $window.localStorage[key] or defaultValue
    setObject: (key, value) ->
      $window.localStorage[key] = JSON.stringify(value)
      return
    getObject: (key) ->
      JSON.parse $window.localStorage[key] or "{}"
    getArray: (key) ->
      JSON.parse $window.localStorage[key] or "[]"
  )
]

bumblebee.factory 'customHttpInterceptor', ($q, $localstorage, $location)-> # http://docs.angularjs.org/api/ng.$http#description_interceptors
  request: (config)->
    config.headers["Accept"] += "; version=" + glo_version
    user = $localstorage.getObject 'user'
    config.headers['Authorization'] = "Token " + user.rememberToken if user.id
    return config || $q.when(config)
  # response: (response)->
  #   return response || $q.when(response)
  responseError: (rejection)->
    switch rejection.status
      when 401
        if $location.path() isnt "/login"
          $location.path("/login")
      when 403 then alert "无访问权限"
      when 429 then alert "请求频率过高"
      else
        if glo_debug
          alert JSON.stringify rejection
        else
          alert "网络不给力！"
    return $q.reject(rejection)

bumblebee.config ["$stateProvider", "$httpProvider", "$urlRouterProvider", ($stateProvider, $httpProvider, $urlRouterProvider)->
  $httpProvider.interceptors.push "customHttpInterceptor"
  # $localstorage = $localstorageProvider.$get[1]() #http://stackoverflow.com/a/17846807/346701

  $stateProvider.state "login",
    url: "/login"
    templateUrl: "templates/login.html"
    controller: "LoginCtrl"
  .state "register",
    url: "/register"
    templateUrl: "templates/register.html"
    controller: "RegisterCtrl"

  $stateProvider.state "app",
    url: "/app"
    abstract: true
    templateUrl: "templates/menu.html"
    controller: "AppCtrl"

  $stateProvider.state "app.home",
    url: "/home"
    views:
      menuContent:
        templateUrl: "templates/home.html"
        controller: 'HomeCtrl'

  $stateProvider.state("app.transes",
    url: "/transes"
    views:
      menuContent:
        templateUrl: "templates/transes.html"
        controller: "TransesCtrl"
  ).state("app.main.trans",
    url: "/trans/:id"
    views:
      menuContent:
        templateUrl: "templates/trans.html"
        controller: "TransCtrl"
    resolve:
      transaction: ($stateParams, TransService) ->
        TransService.get $stateParams.id
  )

  $stateProvider.state("app.me",
    url: "/me"
    views:
      menuContent:
        templateUrl: "templates/me.html"
        controller: "MeCtrl"
  ).state("app.change-password",
    url: "/change-password"
    views:
      menuContent:
        templateUrl: "templates/change-password.html"
        controller: "ChangePasswordCtrl"
  ).state("app.change-nickName",
    url: "/change-nickName"
    views:
      menuContent:
        templateUrl: "templates/change-nickName.html"
        controller: "ChangeNickNameCtrl"
  ).state("app.change-phone",
    url: "/change-phone"
    views:
      menuContent:
        templateUrl: "templates/change-phone.html"
        controller: "ChangePhoneCtrl"
  )

  $stateProvider.state "app.common",
    url: "/common"
    views:
      menuContent:
        templateUrl: "templates/common.html"
        controller: "CommonCtrl"

  $stateProvider.state "app.favor",
    url: "/favor"
    views:
      menuContent:
        templateUrl: "templates/favor.html"
        controller: "FavorCtrl"

  $stateProvider.state "app.feedback",
    url: "/feedback"
    views:
      menuContent:
        templateUrl: "templates/feedback.html"
        controller: "FavorCtrl"

  # if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise "/app/home"

  # http://goo.gl/BNXTb8 原则上不应该采用form提交，但浏览器会针对json提交发起OPTIONS请求，浪费资源。
  # $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
  # $httpProvider.defaults.headers.put['Content-Type'] = 'application/x-www-form-urlencoded'
  # $httpProvider.defaults.transformRequest.unshift (data, headersGetter)->
  #   result = []
  #   for key of data
  #     result.push encodeURIComponent(key) + "=" + encodeURIComponent(data[key]) if data.hasOwnProperty(key)
  #   result.join "&" # http://stackoverflow.com/a/19633847/346701

  return
]

bumblebee.controller "AppCtrl", ($scope, $stateParams, $location, $http, $localstorage, $ionicScrollDelegate, $timeout) ->
  # $scope.menuItemClicked = ->
  $http.get glo_domain + "users/validation"
  $scope.user = $localstorage.getObject 'user'

  scrollBottom = ->
    $ionicScrollDelegate.resize()
    $timeout ->
      $ionicScrollDelegate.scrollBottom true
    , 1
  # https://github.com/driftyco/ionic-plugins-keyboard
  window.addEventListener 'native.keyboardshow', (e)->
    footer = $("footer.bar-footer")
    if footer.css("bottom") is e.keyboardHeight+"px" then return
    footer.css "bottom", e.keyboardHeight
    $("ion-content.dialog-box").css "bottom", e.keyboardHeight
    scrollBottom()
  window.addEventListener 'native.keyboardhide', ->
    footer = $("footer.bar-footer")
    if footer.css("bottom") is "0px" then return
    footer.css "bottom", 0
    $("ion-content.dialog-box").css "bottom", 0
    scrollBottom()

$.notify.defaults
  style: 'bootstrap'
  globalPosition: 'top right'
  autoHideDelay: 5000