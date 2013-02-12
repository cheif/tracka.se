app = angular.module('tracking', []).
    config(['$routeProvider', ($routeProvider) ->
        $routeProvider.
            when('/detail/:id', {controller: 'DetailController', templateUrl: 'detail'}).
            otherwise({redirectTo: '/'})
    ])

app.controller 'SearchController', ($scope, $location) ->
    $scope.searches = JSON.parse(localStorage.searches)

    $scope.addSearch = () ->
        $location.path('/detail/' + $scope.kollinr)
        if not $scope.kollinr in $scope.searches
            $scope.searches.push $scope.kollinr
            localStorage.searches = JSON.stringify($scope.searches)

    
app.controller 'DetailController', ($scope, $routeParams, $http) ->
    $http.get('/tracking/' + $routeParams.id).success((data) =>
        $scope.detailData = data
    )
    
angular.bootstrap document, ['tracking']
