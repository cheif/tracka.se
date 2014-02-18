app = angular.module('tracking', []).
    config(['$routeProvider', ($routeProvider) ->
        $routeProvider.
            when('/detail/:id', {controller: 'DetailController', templateUrl: 'detail'}).
            otherwise({redirectTo: '/'})
    ]).service('searches', ($rootScope) ->
        if not localStorage.searches
            #Initialize the localstorage
            localStorage.searches = JSON.stringify([])
        searches = JSON.parse(localStorage.searches)
        return {
            addSearch: (search) ->
                if searches.filter((eln)-> return eln.id == search.id).length == 0
                    searches.push {id: search.id, sender: search.sender, service: search.service}
                    localStorage.searches = JSON.stringify(searches)
            getSearches: ->
                return searches
        }
    )

app.controller 'SearchController', ($scope, $location, searches) ->
    $scope.searches = searches.getSearches()
    
    $scope.addSearch = () ->
        $location.path('/detail/' + $scope.kollinr)

    
app.controller 'DetailController', ($scope, $routeParams, $http, searches) ->
    $http.get('/tracking/' + $routeParams.id).success((search) =>
        $scope.detailData = search
        searches.addSearch(search)
    )
    
angular.bootstrap document, ['tracking']
