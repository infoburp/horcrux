app = angular.module 'app.controllers', ['ngRoute']

io = window.io.connect 'http://horcrux.nwsco.org:3000'

# ------------------------------------------------------------------

app.controller 'Main', ['$scope', '$route', '$routeParams', '$location', '$xhr', ($scope, $route, $routeParams, $location, $xhr) ->
	$scope.loaded = true
	$scope.$route = $route
	$scope.$location = $location
	$scope.$routeParams = $routeParams
	$scope.$xhr = $xhr

	$scope.$on '$stateChangeSuccess', (e) ->
		return unless window.ga
		window.ga 'send', 'pageview', page: $location.path()
]

# ------------------------------------------------------------------

app.controller 'Index', ['$scope', '$routeParams', ($scope, $routeParams) ->
	$scope.$parent.isHome = 1
	$scope.notes = []
	$scope.loading = true

	$scope.$xhr.fetch('notes').then (results) ->
		$scope.notes.push n for n in results.data
		$scope.loading = false

	io.on 'updateHomepage', (newNote) -> $scope.$apply ->
		$scope.notes.unshift newNote

	io.on 'updateReplies', (newReply) ->
		for n, _ in $scope.notes
			if n.id is newReply.note_id
				$scope.notes[_].cc += 1
				$scope.$apply()
]

# ------------------------------------------------------------------

app.controller 'Single', ['$scope', '$routeParams', ($scope, $routeParams) ->
	$scope.$parent.isHome = 0
	$scope.loading = true

	$scope.$xhr.fetch("note/#{$routeParams.noteId}", null, null, true).then (results) ->
		$scope.note = results.data

	$scope.replies = []
	$scope.$xhr.fetch("note/#{$routeParams.noteId}/replies").then (results) ->
		$scope.replies.push r for r in results.data
		$scope.loading = false

	io.on 'updateReplies', (newReply) ->
		return if newReply.note_id isnt parseInt($routeParams.noteId)

		$scope.$apply -> $scope.replies.push newReply
		$scope.$broadcast 'searchForNests'
]