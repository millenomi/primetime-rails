
$ = jQuery

class Channel
	constructor: (@tag) ->
		# pass
	
	content: (done) ->
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
		@content (response) ->
			image = null
			if response.data and response.data.items and response.data.items.length > 0
				image = $('<img>').attr src: response.data.items[0].thumbnail.hqDefault
				
			done.call(this, image)

overlay =
	element: -> $('#overlay')
	visible: false
	show: ->
		el = @element()
		return unless el
		
		@updateChannelPicker()
		
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
		
	updateChannelPicker: ->
		picker = @element().find('#channels-list')
		
		picker.html ''
		picker.css width: (350 * player.channels.length) + "px"
		_.forEach player.channels, (chan) ->
			chan.thumbnail (image) ->
				console.log 'indexof', chan, _.indexOf(player.channels, chan)
			
				chanElement = $('<div></div>').addClass('channel').append($('<h1></h1>').text(@tag)).append(image)
				
				chanElement.addClass('current') if _.indexOf(player.channels, chan) == player.currentChannelIndex
				chanElement.css cursor: 'pointer'
				
				picker.append(chanElement)
				
				chanElement.click ->
					player.loadChannel(chan)
				
player = 
	youtube: null
	channels: [new Channel('revision 3'), new Channel('kittens'), new Channel('autobots')] # TODO caricare dalla profilazione; TODO 2 usa backbone.js
	loadChannel: (chan) ->
		performLoading = =>
			chan.content (response) =>
				items = response.data.items
				@youtube.loadPlaylist(video.id for video in items)
				@currentChannelIndex = _.indexOf(@channels, chan)
					
		if @youtube
			performLoading()
		else
			@nextChannelLoad = performLoading
	
	ready: (@youtube) ->
		return unless @youtube
		
		if @nextChannelLoad
			@nextChannelLoad()
			@nextChannelLoad = null
				
@onYouTubePlayerReady = (ident) ->
	youtube = $('#player object')[0]
	unless youtube.playVideo
		youtube = $('#player embed')[0]
		
	player.ready(youtube)
	
# ----------------------------------------

$(document).ready ->		

	body = $(document.body)
	
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