requirejs.config
	baseUrl: 'js/'
	urlArgs: "bust=#{(new Date()).getTime()}"
	waitTimeout: 0

require [
	'controllers',
	'directives',
	'services',
	'filters',
], ->
	angular.element(document).ready ->
		angular.module 'app', [
			'app.controllers',
			'app.directives',
			'app.services',
			'app.filters',
		]

		angular.bootstrap document, ['app']