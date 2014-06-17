#!/usr/bin/python

import json
from os import listdir
from os.path import isfile, join
import xml.dom.minidom 

if ( __name__ == "__main__"):
    journal_names = []
    root_dir = "./xmls"
    journals = [ f for f in listdir(root_dir) if isfile(join(root_dir,f)) ]
    for journal in journals:
        doc = xml.dom.minidom.parse(root_dir + "/" + journal)
        journal_name = doc.getElementsByTagName("dblp")[0].getElementsByTagName("article")[0].getElementsByTagName("journal")[0].firstChild.data
        journal_names.append(journal_name)
        print journal_name

    with open('journals.json', 'w') as outfile:
        json.dump(journal_names, outfile)

