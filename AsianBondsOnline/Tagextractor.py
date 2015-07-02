from time import mktime, sleep, localtime
from datetime import datetime
import evernote.edam.userstore.constants as UserStoreConstants
from evernote.edam.notestore.ttypes import NoteFilter, NotesMetadataResultSpec
from evernote.api.client import EvernoteClient
from evernote.edam.type.ttypes import *
from evernote.edam.error.ttypes import *
import requests
import gzip
import zipfile

try:
    import zlib
    compression = zipfile.ZIP_DEFLATED
except:
    compression = zipfile.ZIP_STORED

modes = { zipfile.ZIP_DEFLATED: 'deflated',
          zipfile.ZIP_STORED:   'stored',
          }




def login():
    prod_token = "S=s223:U=2fd1532:E=1551bed32cb:C=14dc43c03a8:P=1cd:A=en-devtoken:V=2:H=a293da7b8f48c52891d376515a988bec"
    client = EvernoteClient(token=prod_token, sandbox=False)
    global rateLimitFlag
    global authExpiryFlag
    rateLimitFlag = False
    authExpiryFlag = False
    return client;


def pullNotes(client, notefilter, count, notespec):
    results = note_store.findNotesMetadata(notefilter, count, 100000, notespec)

    return results;


def getNoteStores(client):
    # just do a simple 2 try call to get note stores
    try:
        user_store = client.get_user_store()
    except EDAMSystemException, e:
        if e.errorCode == 19:
            print "Rate limit reached"
            print "(" + str(datetime.now()) + ")Trying your request in %d seconds" % e.rateLimitDuration
            sleep(e.rateLimitDuration + 10)
            user_store = client.get_user_store()

    version_ok = user_store.checkVersion(
        "Evernoter",
        UserStoreConstants.EDAM_VERSION_MAJOR,
        UserStoreConstants.EDAM_VERSION_MINOR
    )
    print "Is my Evernote API version up to date? ", str(version_ok)
    print ""
    if not version_ok:
        exit(1)

    try:
        biz_note_store = client.get_business_note_store()
    except EDAMSystemException, e:
        if e.errorCode == 19:
            print "Rate limit reached"
            print "(" + str(datetime.now()) + ")Trying your request in %d seconds" % e.rateLimitDuration
            sleep(e.rateLimitDuration + 10)
            biz_note_store = client.get_business_note_store()

    biz_notebooks = biz_note_store.listNotebooks()
    print "Found ", len(biz_notebooks), "business notebooks:"
    for notebook in biz_notebooks:
        print "  * ", notebook.name

    try:
        personal_note_store = client.get_note_store()
    except EDAMSystemException, e:
        if e.errorCode == 19:
            print "Rate limit reached"
            print "(" + str(datetime.now()) + ")Trying your request in %d seconds" % e.rateLimitDuration
            sleep(e.rateLimitDuration + 10)
            personal_note_store = client.get_note_store()

    notebooks = personal_note_store.listNotebooks()
    print "Found ", len(notebooks), "personal notebooks:"
    for notebook in notebooks:
        print "  * ", notebook.name

    if business:
        return [biz_note_store]
    else:
        return [personal_note_store]


def zipAndSend(fileName):

    print 'creating archive'
    zf = zipfile.ZipFile(fileName.replace('txt','zip'), mode='w')
    try:
        print 'adding README.txt with compression mode', modes[compression]
        zf.write(fileName, compress_type=compression)
    finally:
        print 'closing'
        zf.close()

    return requests.post(
        "https://api.mailgun.net/v3/sandbox892958e88b924228ae99fe52a5b679f0.mailgun.org/messages",
        auth=("api", "key-7cd08e4136f4a21e82339c094e93c5d2"),
        files=[("attachment", open(zf.filename))],
        data={"from": "Mailgun Sandbox <postmaster@sandbox892958e88b924228ae99fe52a5b679f0.mailgun.org>",
              "to": "msd <zotrium@gmail.com>",
              "subject": "Tags collection ",
              "text": ""})


def writeToFile():
    fileName = "tagCollection(" + startDate.strftime('%Y%m%d') + ")-(" + endDate.strftime('%Y%m%d') + ")-" + str(count) + ".txt"
    fo = open(fileName, "wb")
    if autoSum:
        fo.write("Tag" + delimiter + "Count" + delimiter + "\n")
        for keypair in tagDictionary.items():
            fo.write(str(keypair[0]) + delimiter + str(keypair[1]) + "\n")
    elif riskSummary:
        fo.write(
            "Date" + delimiter + "ID" + delimiter + "Title" + delimiter + "CountrySectorTag" + delimiter + "RiskTag" + delimiter + "\n")
        for currentOb in arrayOfRiskCountry:
            fo.write(
                str(currentOb[0]) + delimiter + str(currentOb[1]) + delimiter + str(currentOb[2]) + delimiter + str(
                    currentOb[3]) + delimiter + str(currentOb[4]) + "\n")
    else:
        fo.write("Date" + delimiter + "ID" + delimiter + "Title" + delimiter + "Tag" + delimiter + "\n")
        for keypair in arrayOfDateTagTuples:
            fo.write(str(keypair[0]) + delimiter + str(keypair[1]) + delimiter + str(keypair[2]) + delimiter + str(
                keypair[3]) + "\n")

    fo.close()

rateLimitFlag = False
authExpiryFlag = False
retry = True

# region User Input
while retry:
    # startdate_input = raw_input("Please enter start date (YYYYMMDD):")
    startdate_input = "20150401"
    # enddate_input = raw_input("Please enter end date (YYYYMMDD):")
    enddate_input = "20160101"
    # businessorpersonal = raw_input("Business or personal(B/P):")
    businessorpersonal = "B"
    # riskSummary_input = raw_input("RiskSummary Report? (Y/N)")
    riskSummary_input = "N"
    riskSummary = (riskSummary_input == "Y")
    # startFromWhichNote_input = raw_input("Starting note number? (Hint check from previous run count result")
    startFromWhichNote_input = "0"
    # autosum_input = raw_input("Autosum? (Y/N)")
    autosum_input = "N"
    autoSum = (autosum_input == "Y")
    if not autoSum:
        # tagsInOneLine_input = raw_input("Merge tags in one line? (Y/N)")
        tagsInOneLine_input = "N"

    startDate = datetime.strptime(startdate_input, '%Y%m%d')
    endDate = datetime.strptime(enddate_input, '%Y%m%d')

    business = (businessorpersonal == "B")
    startFromWhichNote = int(startFromWhichNote_input)
    tagsInOneLine = (tagsInOneLine_input == "Y")

    if startDate > endDate:
        print "Start date has to be earlier than end date!"
        retry = True
    else:
        retry = False
# endregion

startProcess = True
count = startFromWhichNote
tagDictionary = {}
arrayOfDateTagTuples = []
arrayOfRiskCountry = []

while startProcess:
    startProcess = False
    myClient = login()
    myNoteStores = getNoteStores(myClient)

    noteFilter = NoteFilter(order=NoteSortOrder.CREATED)
    noteFilter.ascending = False
    spec = NotesMetadataResultSpec()
    spec.includeTitle = True
    spec.includeTagGuids = True
    spec.includeCreated = True

    for note_store in myNoteStores:
        print "Extracting from 2014-04-01 to current date ... this may take a while"
        tagsInfo = note_store.listTags()

        tagArray = [(o.guid, o.name) for o in tagsInfo]
        riskTags = [t for t in tagArray if t[1].find("Risk") >= 0]

        delimiter = "\t"
        fallInRange = False
        pullMoreNotes = True

        try:
            while pullMoreNotes:
                pullResult = pullNotes(myClient, noteFilter, count, spec)
                # If pulling has an exception, then just write to file first and continue manually again
                if pullResult == None:
                    writeToFile()
                    quit()

                print "(" + str(datetime.now()) + ") Pulled :" + str(len(pullResult.notes)) + ", Total notes:" + str(
                    pullResult.totalNotes) + ", Currently at " + str(count)

                for note in pullResult.notes:
                    tagsForThisNote = note.tagGuids
                    tag = "No tag"
                    title = "No title"
                    properDate = ""
                    year = ""
                    month = ""
                    day = ""
                    noteGuid = note.guid

                    if note.created is not None:
                        currentTimeStamp = localtime(note.created / 1000)
                        dt = datetime.fromtimestamp(mktime(currentTimeStamp))
                        year = str(dt.year)
                        month = str(dt.month)
                        day = str(dt.day)
                        properDate = str(dt)

                        if dt >= startDate and dt <= endDate:
                            fallInRange = True
                            if note.title is not None:
                                title = note.title

                            final = ""

                            if tagsForThisNote is not None:
                                res = [[x[0] for x in tagArray].index(y) for y in tagsForThisNote if y is not None]
                                if res is not None:
                                    listOfTags = [tagArray[x][1] for x in res]

                                    if riskSummary:
                                        # Perform country + risk combo
                                        countriesAndSectors = ["US", "ASIA"]

                                        # for this article, combine every country and risk tags tgoether and output a row
                                        comboList = [(x, y) for x in listOfTags for y in countriesAndSectors]

                                        for combo in comboList:
                                            arrayOfRiskCountry.extend([dt, noteGuid, title, combo[0], combo[1]])

                                    if autoSum:
                                        for tag in listOfTags:
                                            tagCount = 0

                                            if tagDictionary.has_key(tag):
                                                tagCount = tagDictionary[tag]
                                            tagDictionary[tag] = tagCount + 1
                                    else:
                                        if tagsInOneLine:
                                            mergedTags = "|".join(listOfTags)
                                            arrayOfDateTagTuples.extend([(dt, noteGuid, title, mergedTags)])
                                        else:
                                            arrayOfDateTagTuples.extend(
                                                [(dt, noteGuid, title, tag) for tag in listOfTags if tag is not None])

                                            # print tagDictionary

                        # If we have finished the range of dates we wanted, then quit since it is sorted
                        elif fallInRange == True:
                            pullMoreNotes = False
                            break;

                    count += 1

                if count >= pullResult.totalNotes:
                    break

        except EDAMSystemException, e:
            if e.errorCode == 19:
                rateLimitFlag = True
                print "Rate limit reached"
                print "(" + str(datetime.now()) + ")Trying your request in %d seconds" % e.rateLimitDuration
                sleep(e.rateLimitDuration + 10)
                startProcess = True

        except EDAMUserException, e:
            if e.errorCode == 9:
                authExpiryFlag = True
                print "Auth token expired."
                startProcess = True

writeToFile()

print 'Complete'
quit()
