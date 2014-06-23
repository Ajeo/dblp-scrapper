#!/usr/bin/python

import json
import xml.dom.minidom

if ( __name__ == "__main__"):
    journal_names = []
    journals_map = {}

    json_data = open('./data.json')
    journals = json.load(json_data)
    json_data.close()

    for journal in journals:
        doc = xml.dom.minidom.parse("./xmls/" + journal["id"])
        journal_name = doc.getElementsByTagName("dblp")[0].getElementsByTagName("article")[0].getElementsByTagName("journal")[0].firstChild.data
        journal_names.append(journal_name)

        only_name = journal["name"].replace("IEEE Transactions on ", "").replace("ACM Transactions on ", "")
        journals_map[journal_name.replace(" ", '_').replace(".", '').lower()] = only_name

        print journal_name

    with open('journals.json', 'w') as outfile:
        json.dump(journal_names, outfile)

    with open('journals_map.json', 'w') as outfile:
        json.dump(journals_map, outfile)

