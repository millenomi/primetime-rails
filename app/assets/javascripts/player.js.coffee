
$ = jQuery

class Channel
	constructor: (@tag) ->
		# pass
	
	content: (done) ->
		$.ajax
			url: 'https://gdata.youtube.com/feeds/api/videos',
			method: 'GET',
			data:
				q: chan
				v: 2
				alt: 'jsonc'
			dataType: 'json'
			success: (response) =>
				done(response)
	
	thumbnail: (done) ->
		@content (response) ->
			image = null
			if response.items and response.items.length > 0
				image = $('img').attr src: response.items[0].thumbnails.sqDefault
				
			done(image)

overlay =
	element: -> $('#overlay')
	show: ->
		el = @element()
		return unless el
		
		el.css opacity: 0
		el.show()
		window.setTimeout(=>
			el.animate opacity: 1, 200
		, 0)
	hide: ->
		el = @element()
		return unless el
		
		el.animate opacity: 0, 400, =>
			el.hide()
	hideWithoutAnimation: ->
		el = @element()
		return unless el
		
		el.hide()
		
player = 
	youtube: null
	channels: [new Channel('kittens')] # TODO caricare dalla profilazione; TODO 2 usa backbone.js
	loadChannel: (chan) ->
		performLoading = =>
			chan.content (response) =>
				items = response.data.items
				@youtube.loadPlaylist(video.id for video in items, 0, 0, 'hd720')
					
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
	

$(document).ready ->		

	body = $(document.body)
	
	overlay.hideWithoutAnimation()
	player.loadChannel player.channels[0]
	
	body.mouseenter ->
		overlay.show()
		
	body.mouseleave ->
		overlay.hide()
	
	