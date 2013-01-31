class Search
    @oldsearches: []
    constructor: (data) ->
        @id = data.id
        @service = data.service
        @sender = data.sender
    
    save: () ->
        existing = Search.oldsearches.map (s) -> s.id
        if not (@id in existing)
            Search.oldsearches.push @
            localStorage.oldsearches = JSON.stringify(Search.oldsearches)
            @render()

    render: () ->
        $('#oldsearches li').removeClass('active')
        $('#oldsearches').prepend('<li><a>' + @id + '</a></li>')

    @load: ()->
        if localStorage.oldsearches
            searches = JSON.parse(localStorage.oldsearches)
            for s in searches
                search = new Search(s)
                search.save()


class Tracking
    constructor: ->
        Search.load()
        @bindInput()
        @bindList()

    bindInput: ->
        $('#kollinr').bind 'change', (evt) =>
            @doSearch(evt.target.value)
    
    bindList: ->
        $('#oldsearches li').bind 'click', (evt) =>
            @doSearch(evt.target.innerHTML)
            $(evt.target).parent().addClass('active')

    doSearch: (kollinr) ->
        $('#events tbody').html('<img src="/ajax-loader.gif"></img>')
        $('#details').show()
        $.getJSON('/tracking/' + kollinr , (data) =>
            $('.kollinr').html(data.id)
            $('#events tbody').empty()
            for event in data.events
                row = "<tr>"
                row += "<td>" + event.date + "</td>"
                row += "<td>" + event.location+ "</td>"
                row += "<td>" + event.message + "</td>"
                row += "</tr>"
                $('#events tbody').append(row)

            search = new Search(data)
            search.save()
        )

$ ->
    window.tracking = new Tracking

