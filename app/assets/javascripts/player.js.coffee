
$ = jQuery

class Channel
	constructor: -> #pass

	content: (done) ->
		done(null)
		
	thumbnail: (done) ->
		done(null)
				
class RecommendationsChannel extends Channel
	tag: 'For you'

	rawContent: (done) ->
		$.ajax
			url: '/recommendations'
			method: 'GET'
			dataType: 'json'
			success: (response) =>
				done.call(this, response)
			
	content: (give) ->
		@rawContent (result) ->
			give(video.id for video in result.data.items)
			
	otherChannels: (give) ->
		@rawContent (result) ->
			hash = {}
			for video in result.data.items
				for tag in video.tags
					hash[tag] = 0 unless hash[tag]
					hash[tag]++
			
			allTags = (tag for own tag, count of hash)
			allTags.sort (x, y) ->
				hash[y] - hash[x]
			
			give allTags
			
	thumbnail: (give) ->
		@rawContent (response) ->
			image = null
			if response.data and response.data.items and response.data.items.length > 0
				image = $('<img>').attr src: response.data.items[0].thumbnail.hqDefault
				
			give image
		

class SearchChannel extends Channel
	constructor: (@tag) ->
		# pass
	
	content: (give) ->
		@rawContent (response) ->
			give(video.id for video in response.data.items)
	
	rawContent: (done) ->
		$.ajax
			url: 'https://gdata.youtube.com/feeds/api/videos',
			method: 'GET',
			data:
				q: @tag
				v: 2
				alt: 'jsonc'
			dataType: 'json'
			success: (response) =>
				done.call(this, response)
	
	thumbnail: (done) ->
		@rawContent (response) ->
			image = null
			if response.data and response.data.items and response.data.items.length > 0
				image = $('<img>').attr src: response.data.items[0].thumbnail.hqDefault
				
			done.call(this, image)

overlay =
	element: -> null
	ready: (el) ->
		@element = -> el
		$(document.body).bind player.didChangeCurrentChannel, () =>
			@updateChannelSelection()
		
		$(document.body).bind player.didChangeChannels, () =>
			@updateChannelPicker()
		
	visible: false
	show: ->
		el = @element()
		return unless el
		
		# @updateChannelPicker()
		
		el.css opacity: 0
		el.show()
		window.setTimeout(=>
			el.animate opacity: 1, 200
		, 0)
		
		@visible = true
		
	hide: ->
		el = @element()
		return unless el
		
		el.animate opacity: 0, 400, =>
			el.hide()
			
		@visible = false
		
	hideWithoutAnimation: ->
		el = @element()
		return unless el
		
		el.hide()
		@visible = false
		
	updateChannelSelection: ->
		$('#channels-list .channel').removeClass('current')
		
	updateChannelPicker: ->
		picker = @element().find('#channels-list')
		
		picker.html ''

		toLoad = player.channels.length
		loaded = []
		
		_.forEach player.channels, (chan, index) =>
			console.log 'indexof', chan, index
			chan.thumbnail (image) =>
				console.log 'indexof', chan, index
			
				title = chan.tag
				if title.length > 15
					title = title.substr(0, 15) + "…"
			
				chanElement = $('<div></div>').addClass('channel').append($('<h1></h1>').text(title)).append(image)
				
				chanElement.addClass('current') if _.indexOf(player.channels, chan) == player.currentChannelIndex
				chanElement.css cursor: 'pointer'
								
				clickHandler = =>
					player.loadChannel(chan)
					overlay.hide()
					@updateChannelSelection()
				
				chanElement.click clickHandler
					
				console.log clickHandler
					
				loaded[index] = chanElement[0]
				toLoad--
				
				if toLoad == 0
					picker.html ''
					picker.css width: (350 * loaded.length) + "px"
					picker.append $(loaded)
					
	
				
player = 
	didChangeCurrentChannel: 'current-channel-changed.primetime'
	didChangeChannels: 'channels-changed.primetime'

	youtube: null
	channels: [new RecommendationsChannel] # TODO caricare dalla profilazione; TODO 2 usa backbone.js
	loadChannel: (chan) ->
		throw "Chan must be set" unless chan
	
		performLoading = =>
			chan.content (response) =>
				console.log "About to load channel with ids:", response
				@youtube.loadPlaylist(_.sortBy(response, -> Math.random()))
				@currentChannelIndex = _.indexOf(@channels, chan)
				$(document.body).trigger @didChangeCurrentChannel
					
		if @youtube
			performLoading()
		else
			@nextChannelLoad = performLoading
	
	ready: (@youtube) ->
		return unless @youtube
		
		$(document.body).trigger @didChangeChannels
		
		if @nextChannelLoad
			@nextChannelLoad()
			@nextChannelLoad = null
			
		@channels[0].otherChannels (chanTags) =>
			@channels.push(new SearchChannel(x)) for x in chanTags
			$(document.body).trigger @didChangeChannels
		
				
@onYouTubePlayerReady = (ident) ->
	youtube = $('#player object')[0]
	unless youtube.playVideo
		youtube = $('#player embed')[0]
		
	player.ready(youtube)
	
# ----------------------------------------

$(document).ready ->		

	window.player = player
	window.overlay = overlay

	body = $(document.body)
	
	overlay.ready($('#overlay'))
	
	overlay.hideWithoutAnimation()
	player.loadChannel player.channels[0]
	
	
	inside = false
	mouseTimeout = null
	
	body.mouseenter ->
		if not inside
			inside = true
			overlay.show()
			
			hide = -> overlay.hide()
			mouseTimeout = window.setTimeout(hide, 5000)
		
	body.mouseleave ->
		overlay.hide()
		inside = false
		if mouseTimeout != null
			window.clearTimeout(mouseTimeout)
			mouseTimeout = null

	body.mousemove ->
		if inside
			window.clearTimeout(mouseTimeout)
			hide = -> overlay.hide()
			mouseTimeout = window.setTimeout(hide, 5000)
		
		overlay.show() unless overlay.visible
		
	$('#add-channel').click ->
		chan = prompt("Choose a tag for this channel")
		if chan
			chan = new SearchChannel(chan)
			player.channels.push(chan)
			player.loadChannel(chan)
			overlay.updateChannelPicker()
			overlay.hide()
			
			