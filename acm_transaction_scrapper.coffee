casper = require('casper').create()
xmls = []
links = []

getACMTransactionLinks = ->
  urls = []
  anchors = document.querySelectorAll('#main > ul li a')
  for anchor in anchors
    if anchor.innerHTML.match(/^ACM Transactions/) != null
      urls.push anchor.getAttribute('href')

  urls

getIEEETransactionLinks = ->
  urls = []
  anchors = document.querySelectorAll('#main > ul li a')
  for anchor in anchors
    if anchor.innerHTML.match(/^IEEE Transactions/) != null
      urls.push anchor.getAttribute('href')

  urls

getFirstJournalLink = ->
  anchors = document.querySelectorAll('#main > ul li a')
  anchors[0].getAttribute('href')

casper.start "http://dblp.uni-trier.de/db/journals/index-a.html", ->
  links = @evaluate(getACMTransactionLinks)

casper.thenOpen "http://dblp.uni-trier.de/db/journals/index-i.html", ->
  links = links.concat(@evaluate(getIEEETransactionLinks))
  @eachThen links, (resp) ->
    @thenOpen resp.data, (resp) ->
      firstJournalLink = @evaluate(getFirstJournalLink)
      @thenOpen firstJournalLink, (resp) ->
        @echo resp.url
        if resp.url.match(/dblp.uni-trier.de/) != null
          xmls.push @evaluate (link) ->
            xml_path_splited = document.querySelector('.publ-list li').getAttribute("id").split('/')
            xml = xml_path_splited[xml_path_splited.length - 1] + ".xml"
            link_splited = link.split('/')
            link_base = "http://dblp.uni-trier.de/rec/bibtex/journals/#{link_splited[link_splited.length - 2]}"
            {name: xml, url: "#{link_base}/#{xml}"}
          , resp.url
          @echo xmls[xmls.length - 1].url

casper.then ->
  for xml in xmls
    @echo "download #{xml.name}"
    @download xml.url, "./xmls/#{xml.name}"

casper.run ->
  # @echo links
  @exit()

