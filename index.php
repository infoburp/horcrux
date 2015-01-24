<!DOCTYPE html>
<html lang="en">
<head>
	<base href="/" />
	<meta charset="UTF-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimal-ui" />

	<title>[HX]</title>

	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" />
	<link rel="stylesheet" href="//cdn.jsdelivr.net/g/foundation@5.4.7(css/foundation.min.css),normalize@3.0.0" />
	<link rel="stylesheet" href="css/core.css" />

	<!--[if lt IE 9]>
	<script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.6.2/html5shiv.js"></script>
	<script src="//s3.amazonaws.com/nwapi/nwmatcher/nwmatcher-1.2.5-min.js"></script>
	<script src="//html5base.googlecode.com/svn-history/r38/trunk/js/selectivizr-1.0.3b.js"></script>
	<script src="//cdnjs.cloudflare.com/ajax/libs/respond.js/1.1.0/respond.min.js"></script>
	<![endif]-->
</head>
<body>

<section id="content" class="text-center">
	<header>
		<h1>
			<a href="/">horcrux</a>
			<small>leave a piece of yourself</small>
		</h1>
	</header>

	<div ng-controller="Main">
		<div ng-view></div>

		<form post-form method="post" action="javascript:;" ng-submit="submit()" class="is-fixed">
			<div id="popup" ng-show="open" ng-cloak>
				<input
					required
					type="text"
					ng-if="isHome"
					placeholder="Title"
					ng-model="data.title"
					minlength="1"
					ng-cloak />

				<input
					type="hidden"
					ng-if="!isHome"
					ng-model="data.noteId"
					ng-cloak />

				<textarea
					required
					ng-model="data.copy"
					minlength="2"
					placeholder="Add anything you want here.&hellip;"></textarea>

				<small class="text-left">
					Shift + Enter to submit
				</small>
			</div>

			<div id="popup-actions">
				<a href="javascript:;" ng-click="open = true; focus()" ng-show="!open && loaded" ng-cloak>
					{{ isHome ? 'Create New' : 'Add Reply' }}
				</a>

				<a class="cancel-action" href="javascript:;" ng-click="open = false" ng-show="open" ng-cloak>
					<i class="fa fa-times"></i>
				</a>

				<button type="submit" ng-show="open" ng-cloak>
					{{ isHome ? 'Submit' : 'Comment' }}
				</button>
			</div>
		</form>
	</section>
</section>

<!-- Scripts -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.22/angular.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.22/angular-route.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.22/angular-sanitize.min.js"></script>
<script src="//cdn.jsdelivr.net/momentjs/2.9.0/moment.min.js"></script>
<script src="http://horcrux.nwsco.org:3000/socket.io/socket.io.js"></script>
<script data-main="js/core" src="//cdnjs.cloudflare.com/ajax/libs/require.js/2.1.9/require.min.js"></script>

<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-10405648-13', 'auto');
ga('send', 'pageview');
</script>

</body>
</html>