app = angular.module 'app.filters', ['ngSanitize']

# ------------------------------------------------------------------

app.filter 'trust', ['$sce', ($sce) ->
	(src) -> $sce.trustAsResourceUrl src
]

# ------------------------------------------------------------------

app.filter 'nl2br', -> (text) -> text.replace /\n/g, '<br />' if text?

# ------------------------------------------------------------------

app.filter 'reverse', -> (obj) -> obj.slice().reverse()

# ------------------------------------------------------------------

app.filter 'objLength', -> (obj) ->
	i = 1
	i++ for z of obj
	i

# ------------------------------------------------------------------

app.filter 'globalFilters', ->
	isImgUrl = /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi

	services = /(imgur|ytimg|blogspot|imgh)/
	accepted = ['jpg', 'gif', 'jpeg', 'png']

	testType = (types, ext) -> types.indexOf(ext) > -1

	(text, target = '_blank') ->
		return '' unless text

		angular.forEach text.match(isImgUrl), (url) ->
			ext = url.split('.').pop().toLowerCase()
			replacement = "<a target=#{target} href=#{url}>#{url}</a>"

			# Images
			if services.test(url) and testType(accepted, ext)
				replacement = "<img src=#{url} />"

			text = text.replace url, replacement

		text.replace /(?:\r\n|\r|\n)/g, '<br />'

# ------------------------------------------------------------------

app.filter 'truncate', -> (text, len) ->
	if text
		words = text.split ''

		if words.length > len
			text = words.slice(0, len).join('') + '…'
	text

# ------------------------------------------------------------------

app.filter 'replyLinks', ->
	pattern = /(>>[0-9]+)/g

	(text) ->
		angular.forEach text.match(pattern), (id) ->
			text = text.replace id, "<a class=reply-link>#{id}</a>"
		text

# ------------------------------------------------------------------

app.filter 'fromNow', -> (date) -> window.moment(date).fromNow()
