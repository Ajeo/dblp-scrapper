casper = require('casper').create()
fs = require('fs')

xmls = []
links = []

getACMTransactionLinks = ->
  urls = []
  anchors = document.querySelectorAll('#main > ul li a')
  for anchor in anchors
    if anchor.innerHTML.match(/^ACM Transactions/) != null
      urls.push {name: anchor.innerHTML, link: anchor.getAttribute('href')}

  urls

getIEEETransactionLinks = ->
  urls = []
  anchors = document.querySelectorAll('#main > ul li a')
  for anchor in anchors
    if anchor.innerHTML.match(/^IEEE Transactions/) != null
      urls.push {name: anchor.innerHTML, link: anchor.getAttribute('href')}

  urls

getFirstJournalLink = ->
  anchors = document.querySelectorAll('#main > ul li a')
  if anchors[0].getAttribute('href').lastIndexOf(".html") != -1
    anchors[0].getAttribute('href')
  else
    ""

casper.start "http://dblp.uni-trier.de/db/journals/index-a.html", ->
  links = @evaluate(getACMTransactionLinks)

casper.thenOpen "http://dblp.uni-trier.de/db/journals/index-i.html", ->
  links = links.concat(@evaluate(getIEEETransactionLinks))

casper.then ->
  @eachThen links, (resp) ->
    journal = resp.data
    @thenOpen journal.link, (resp) ->
      @echo journal.link
      firstJournalLink = @evaluate(getFirstJournalLink)
      if firstJournalLink.length > 0
        @thenOpen firstJournalLink, (resp) ->
          if resp.url.match(/dblp.uni-trier.de/) != null
            xmls.push @evaluate (link, journal_name) ->
              xml_path_splited = document.querySelector('.publ-list li').getAttribute("id").split('/')
              xml = xml_path_splited[xml_path_splited.length - 1] + ".xml"
              link_splited = link.split('/')
              link_base = "http://dblp.uni-trier.de/rec/bibtex/journals/#{link_splited[link_splited.length - 2]}"
              {id: xml, name: journal_name, url: "#{link_base}/#{xml}"}
            , resp.url, journal.name
            @echo xmls[xmls.length - 1].name

casper.then ->
  for xml in xmls
    @echo "download #{xml.name}"
    @download xml.url, "./xmls/#{xml.id}"

casper.then ->
  fs.write('./data.json', JSON.stringify(xmls, null, '  '), 'w')

casper.run ->
  # @echo links
  @exit()

