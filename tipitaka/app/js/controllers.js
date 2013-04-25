'use strict';

/* Controllers */


function canonCtrl($scope, $routeParams, $location, tvServ, paliXml, htmlDoc2View, i18nTpkServ) {
  // determine basic pali text path
  var paliTextPath = '/';
  if (angular.isDefined($routeParams.urlLocale))
     paliTextPath += $location.path().split('/')[2];
  else
     paliTextPath += $location.path().split('/')[1];
  if (angular.isDefined($routeParams.canonPath))
    paliTextPath += ('/' + $routeParams.canonPath);

  var info = tvServ.getInfo(paliTextPath);

  $scope.pathBreadcrumbs = info.pathBreadcrumbs;

  if (!info.hasOwnProperty('action')) {
    // not leaf node => shows only links
    $scope.nodes = info.childNodesInfo;
    return;
  }

  // leaf node => contains pali texts
  var action = info['action'];

  $scope.text = info['text'];
  $scope.isShowLoading = true;

  var promise = paliXml.get(action);
  promise.then(function(htmlDoc) {
    $scope.isShowLoading = false;
    $scope.xmlDoms = htmlDoc2View.getView(htmlDoc);
    $scope.localeTranslations = i18nTpkServ.getI18nLinks(action);
    if (angular.isDefined($scope.localeTranslations)) {
      $scope.isTranslationAvailableLinks = true;
    }
  }, function(reason) {
    // TODO: error handling here
    $scope.isShowLoading = false;
    console.log(reason);
  });
}
canonCtrl.$inject = ['$scope', '$routeParams', '$location', 'tvServ', 'paliXml', 'htmlDoc2View', 'i18nTpkServ'];


function infoCtrl($scope, i18nTpkServ) {
  // setup translation links
  $scope.localeTranslations = i18nTpkServ.getAllLocalesTranslations();
}
infoCtrl.$inject = ['$scope', 'i18nTpkServ'];


function translationCtrl($scope, $location, $routeParams, i18nTpkServ, paliXml, tvServ) {
  $scope.isShowLoading = true;
  var locale = $location.path().split('/').reverse()[1];
  var url = i18nTpkServ.getTranslationXmlUrl($routeParams.canonPath, locale, $routeParams.translator);
  var info = tvServ.getInfo('/canon/' + $routeParams.canonPath);
  $scope.text = info.text;
  $scope.pathBreadcrumbs = info.pathBreadcrumbs;

  paliXml.getUrl(url).then( function(htmlDoc) {
    $scope.isShowLoading = false;
    $scope.isShowOriPaliLink = true;
    if ($routeParams.urlLocale)
      $scope.oriPaliLink = '/' + $routeParams.urlLocale + '/canon/' + $routeParams.canonPath;
    else
      $scope.oriPaliLink = '/canon/' + $routeParams.canonPath;
    $scope.xmlDoms = angular.element(htmlDoc.getElementsByTagName('body')[0].cloneNode(true));
  }, function(reason) {
    // TODO: error handling here
    $scope.isShowLoading = false;
    console.log(reason);
  });
}
translationCtrl.$inject = ['$scope', '$location', '$routeParams', 'i18nTpkServ', 'paliXml', 'tvServ'];


function contrastReadingCtrl($scope, $location, $routeParams, $q, tvServ, i18nTpkServ, paliXml, htmlDoc2View) {
  $scope.isShowLoading = true;
  var locale = $location.path().split('/').reverse()[2];
  var url = i18nTpkServ.getTranslationXmlUrl($routeParams.canonPath, locale, $routeParams.translator);

  var info = tvServ.getInfo('/canon/' + $routeParams.canonPath);
  $scope.pathBreadcrumbs = info.pathBreadcrumbs;
  $scope.text = info.text;

  var promise = paliXml.get(info.action);
  var promiseTrans = paliXml.getUrl(url);

  $q.all([promise, promiseTrans]).then( function(htmlDocArray) {
    var oriHtmlDoc = htmlDocArray[0];
    var transHtmlDoc = htmlDocArray[1];
    $scope.xmlDoms = htmlDoc2View.getContrastReadingView(oriHtmlDoc, transHtmlDoc);
    $scope.isShowLoading = false;
    $scope.isShowOriPaliLink = true;
    if ($routeParams.urlLocale)
      $scope.oriPaliLink = '/' + $routeParams.urlLocale + '/canon/' + $routeParams.canonPath;
    else
      $scope.oriPaliLink = '/canon/' + $routeParams.canonPath;
  }, function(reason) {
    // TODO: error handling here
    $scope.isShowLoading = false;
    console.log(reason);
  });
}
contrastReadingCtrl.$inject = ['$scope', '$location', '$routeParams', '$q', 'tvServ', 'i18nTpkServ', 'paliXml', 'htmlDoc2View'];

