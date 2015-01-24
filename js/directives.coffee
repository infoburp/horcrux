app = angular.module 'app.directives', []

winObj = angular.element window
docObj = angular.element document

$copy = angular.element '#popup textarea'

raf = (-> (
	window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) -> window.setTimeout callback, 1
))()

# ------------------------------------------------------------------

app.directive 'qScope', -> scope: true

# ------------------------------------------------------------------

app.directive 'replyHover', ->
	restrict: 'C'
	scope: false
	link: (scope, el, attrs) -> docObj.on 'mousemove', (e) ->
		$el = jQuery e.target

		left = e.clientX + 20
		top = e.clientY + 20

		if (top + el.outerHeight()) > winObj.scrollTop()
			top = e.clientY - el.outerHeight() - 20

		el.hide().css
			left: left
			top: top

		if $el.hasClass 'reply-link'
			id = $el.text().replace '>>', ''

			if ($reply = angular.element("[data-id='#{id}']")).length is 1
				el.find('.comment').empty().append $reply.html()
				el.show()

# ------------------------------------------------------------------

app.directive 'replyLinks', ['$timeout', ($timeout) ->
	restrict: 'C'
	scope: false
	link: (scope, el, attrs) ->
		el = el.parents '.comment'
		$links = el.find '.reply-links'

		search = ->
			$links.empty()

			id = el.data().id
			$replies = angular.element "p .reply-link:contains(>>#{id})"

			$replies.each (i, el) ->
				replyId = jQuery(el).parents('.comment').data().id
				$links.append "<a class='reply-link'>>>#{replyId}</a> "

		$timeout search
		scope.$on 'searchForNests', search
]

# ------------------------------------------------------------------

app.directive 'tid', ->
	restrict: 'C'
	scope: false
	link: (scope, el, attrs) -> el.on 'click', (e) ->
		newValue = $copy.val() + ">>#{el.text()}\n"

		$copy.scope().data.copy = newValue
		$copy.scope().open = true
		scope.$apply()

		$copy.focus()

# ------------------------------------------------------------------

app.directive 'postForm', ['$timeout', '$interval', '$xhr', ($timeout, $interval, $xhr) ->
	restrict: 'A'
	scope: true
	link: (scope, el, attrs) ->
		scope.data = {}
		scope.data.copy = ''

		$num = el.find 'num'

		int_prevent = null

		scope.focus = ->
			$timeout -> $copy.focus()
			return

		scope.submit = ->
			return if el.hasClass 'disabled'

			scope.data.noteId = scope.$routeParams.noteId
			uri = if scope.isHome then 'addNote' else 'addReply'

			scope.$xhr.fetch uri, 'POST', scope.data
			scope.data = {}

			el.addClass 'disabled'
			$timeout ->
				el.removeClass 'disabled'
			, 1000

		winObj.on 'keyup', (e) ->
			if e.keyCode is 13 and !$copy.is ':focus'
				scope.$apply ->
					scope.open = true
					scope.focus()

			if e.keyCode is 27 and scope.open
				scope.$apply -> scope.open = false

		$copy.on 'keypress', (e) ->
			if e.keyCode is 13 and e.shiftKey
				e.preventDefault()
				el.find(':submit').click()
]