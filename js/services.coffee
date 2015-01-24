app = angular.module 'app.services', ['ngRoute']

# ------------------------------------------------------------------

app.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
	$routeProvider.when '/',
		controller: 'Index'
		templateUrl: 'home.html'

	$routeProvider.when '/note/:noteId',
		controller: 'Single'
		templateUrl: 'single.html'

	$locationProvider.html5Mode(true).hashPrefix '!'
]

# ------------------------------------------------------------------

app.service '$xhr', ['$http', '$q', ($http, $q) ->
	fetch: (uri, method = 'GET', params = {}, cache = false) ->
		deferred = $q.defer()

		config =
			method: method
			url: 'http://horcrux.io:3000/' + uri
			cache: cache

		if method is 'POST'
			config.dataType = 'json'
			config.data = params

		x = $http config
		x.error (data, status) -> deferred.reject data, status

		x.success (response, status, headers, config) ->
			results = []
			results.data = response
			deferred.resolve results

		deferred.promise
]