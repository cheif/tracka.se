class Search
    @oldsearches: []
    constructor: (kolliid) ->
        @id = kolliid

    doSearch: () ->
        $.getJSON('/tracking/' + @id , (data) =>
            $('#details #kolliid').html(data.id)
            $('#details #sender').html(data.sender)
            $('#details #events tbody').empty()
            for event in data.events
                row = "<tr>"
                row += "<td>" + event.date + "</td>"
                row += "<td>" + event.location+ "</td>"
                row += "<td>" + event.message + "</td>"
                row += "</tr>"
                $('#events tbody').append(row)

            @service = data.service
            @sender = data.sender
            @save()
        )

    save: () ->
        existing = Search.oldsearches.map (s) -> s.id
        if not (@id in existing)
            Search.oldsearches.push @
            localStorage.oldsearches = JSON.stringify(Search.oldsearches)
            @render()

    render: () ->
        eln = $('<li kolliid=' + @id + '><a>' + @id + '<span class="pull-right">' + @service + '</span><br>' + @sender.split('<br>')[0]+ '</a></li>')
        $('#oldsearches').prepend(eln)
        eln.bind 'click', (evt) =>
            @doSearch()

    @load: ()->
        #Load from localstorage
        if localStorage.oldsearches
            searches = JSON.parse(localStorage.oldsearches)
            for s in searches
                search = new Search(s.id)
                search.service = s.service
                search.sender = s.sender
                search.save()


class Tracking
    constructor: ->
        Search.load()
        @bindInputHandler()
        @bindLoadingHandler()

    bindInputHandler: ->
        $('#kollinr').bind 'change', (evt) =>
            new Search(evt.target.value).doSearch()
    
    bindLoadingHandler: ->
        $(document).ajaxStart(=>
            $('#details').hide()
            $('#loading').show()
        )

        $(document).ajaxStop(=>
            $('#details').show()
            $('#loading').hide()
        )
$ ->
    window.tracking = new Tracking

