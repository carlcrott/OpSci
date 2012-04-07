# -*- coding: utf-8 -*-
import sys, os, inspect
from quick_orm.core import Database
from sqlalchemy import Column, Boolean, Integer, String, Text, DateTime
from copy import copy, deepcopy

try:
    import unittest2 as unittest
except ImportError:
    import unittest
if not hasattr(unittest.TestCase, "setUpClass"):
    raise Exception, "install unittest2 or use python2.7"
    sys.exit(1)
TestCase = unittest.TestCase

class Model:
    __metaclass__ = Database.DefaultMeta

class Tag(Model):
    name = Column(String(100))

class Person(Model):
    is_definitely_professor = Column(Boolean(), default=False)
    unparsed_name = Column(String(100))
    first_name = Column(String(100))
    last_name = Column(String(100))
@Database.foreign_key(Person, ref_name='person', backref_name='details')
class PersonDetail(Model):
    person_id = Column(Integer())
    name = Column(String(100)) #like "fax" or "address" or "email"
    value = Column(String(255))

@Database.many_to_many(Person, ref_name='people', backref_name='publishers')
class Publisher(Model):
    name = Column(String(100), unique=True)
    url = Column(String(100), unique=True)

@Database.many_to_many(Person, ref_name='people', backref_name='schools')
class School(Model):
    """keep global records of each school (why not)"""
    url = Column(String(100), unique=True)
    name = Column(String(100), unique=True)
    created_at = Column(DateTime())

@Database.foreign_key('School', ref_name='school', backref_name='proxies')
class EzProxy(Model):
    """for storing known proxies"""
    school_id = Column(Integer())
    
    url = Column(String(100), unique=True)
    created_at = Column(DateTime())
    last_confirmed_at = Column(DateTime())

@Database.foreign_key('EzProxy', ref_name='ezproxy', backref_name='logins')
class EzProxyLogin(Model):
    """for storing usernames/passwords"""
    ezproxy_id = Column(Integer())

    #be sure to explicitly set if this one is working or not
    working = Column(Boolean(), default=False)
    
    #authorization schemes can vary...
    username = Column(String(100))
    password = Column(String(100))
    
    #where was this discovered at?
    discovery_url = Column(String(200))
    
    created_at = Column(DateTime())
    last_working_at = Column(DateTime())
    last_confirmed_at = Column(DateTime())

@Database.foreign_key(EzProxy, ref_name='ezproxy', backref_name='entries')
@Database.foreign_key(Publisher, ref_name='publisher', backref_name='proxies')
class EzProxyEntry(Model):
    """each ezproxy instance has at least one site that it provides access to"""
    ezproxy_id = Column(Integer())
    publisher_id = Column(Integer())
    
    #entry.name should == publisher.name but sometimes ezproxy installations are weird
    name = Column(String(100))

    created_at = Column(DateTime())
    last_confirmed_at = Column(DateTime())

@Database.foreign_key(Publisher, ref_name='publisher', backref_name='journals')
@Database.many_to_many(Person, ref_name='editors', backref_name='journal_editorships')
class Journal(Model):
    publisher_id = Column(Integer())

    #is the journal still alive?
    is_accepting_submissions = Column(Boolean(), default=True)

    #name: Tetrahedron Letters
    name = Column(String(100))
    
    #subtitle: The International Journal for the Rapid Publication of all Preliminary Communications in Organic Chemistry
    subtitle = Column(Text())

    #isbn: 978-1-55938-979-2
    isbn = Column(String(100))

    #issn: 0040-4039
    issn = Column(String(100))
    
    doi = Column(String(255))

    imprint = Column(String(255))

    #"Tetrahedron Letters provides maximum dissemination of outstanding developments in organic chemistry..."
    description = Column(Text())
    
    #http://media.journals.elsevier.com/content/covers/tetrahedron-letters.gif
    cover_url = Column(String(255))

    #http://www.sciencedirect.com/science/journal/00404039
    url = Column(String(255))

    rss_feed = Column(String(255))

    #http://www.sciencedirect.com/science?_ob=PublicationURL&_hubEid=1-s2.0-S0040403911X00497&_cid=271373&_pubType=J&_auth=y&_acct=C000228598&_version=1&_urlVersion=0&_userid=10&md5=5a02106c990d37696ef729e643cb4b5e
    sample_issue_url = Column(String(255))

    #http://ees.elsevier.com/tetl/
    submission_url = Column(String(255))

    #"Tetrahedron Letters provides maximum dissemination..."
    #"The journal would like to enrich online articles by visualising and providing details of chemical structurse"
    submission_text = Column(Text())

    #volume 53
    latest_volume_number = Column(Integer())
    #issue 19
    latest_issue_number = Column(Integer())
    #page 2484
    latest_last_page_number = Column(Integer())
    #2012-05-09
    latest_publication_date = Column(DateTime(), default=None)
    #1900
    founded_year = Column(Integer())

    created_at = Column(DateTime())
    updated_at = Column(DateTime())

@Database.foreign_key(Journal, ref_name='journal', backref_name='volumes')
class Volume(Model):
    journal_id = Column(Integer())
    
    volume_number = Column(Integer())
    issue_number = Column(Integer())
    
    url = Column(String(255))
    doi = Column(String(255))

    #2012-01-01
    published_at = Column(DateTime(), default=None)
    
    #like for journals that are showing a volume but it's not complete yet
    is_future_publication = Column(Boolean(), default=True)

    created_at = Column(DateTime())
    updated_at = Column(DateTime())

@Database.foreign_key(Journal, ref_name='journal', backref_name='papers')
@Database.foreign_key(Volume, ref_name='volume', backref_name='papers')
@Database.many_to_many(Person, ref_name='authors', backref_name='authored_papers', middle_table_name='author_paper')
@Database.many_to_many(Person, ref_name='editors', backref_name='edited_papers', middle_table_name='editor_paper')
@Database.many_to_many(Tag, ref_name='tags', backref_name='papers')
class Paper(Model):
    #foreign keys
    journal_id = Column(Integer())
    volume_id = Column(Integer())

    #doi: 10.1016/j.tetlet.2012.01.125
    doi = Column(String(255))
    url = Column(Text())
    pdf_url = Column(Text())

    #TODO XXX there's probably lots of attributes missing?

    #Solvent free, N,Nâ€²-carbonyldiimidazole (CDI) mediated amidation
    name = Column(Text())

    page_start = Column(Integer())
    page_end = Column(Integer())
    
    received_at = Column(DateTime(), default=None)
    accepted_at = Column(DateTime(), default=None)
    available_online_at = Column(DateTime(), default=None)
    #dead_tree_published_at is self.volume.published_at
    
    created_at = Column(DateTime())
    updated_at = Column(DateTime())

Database.register()

def latin1_encoder(unicode_csv_data):
    for line in unicode_csv_data:
        yield line.encode('latin1')

def unicode_csv_reader(unicode_csv_data, **kwargs):
    #csv.py doesn't do Unicode; encode temporarily as latin1:
    csv_reader = csv.reader(latin1_encoder(unicode_csv_data),
                            **kwargs)
    for row in csv_reader:
        #decode latin1 back to Unicode, cell by cell:
        yield [unicode(cell, 'latin1') for cell in row]

def check_title_snag(journal, other_title):
    if journal["current_title"] != other_title:
        print "current_title: " + journal["current_title"].encode("utf-8")
        print "other_title: " + other_title.encode("utf-8")
        raise Exception, "current_title and other_title aren't the same?"

class Scraper: pass

class ScienceDirectScraper(Scraper):
    database, publisher = None, None
    publisher_url = "www.sciencedirect.com"
    scraper_author = "Bryan Bishop <kanzure@gmail.com>"
    #csv urls are from http://www.info.sciverse.com/sciencedirect/content/journals/titles
    csv_urls = [
                "http://www.info.sciverse.com/techsupport/books/allbooks.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlactive.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnl3rdparty.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlfreeacc.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlnew.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlchanges.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnldiscontinued.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnltransfers.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlremoved.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlforthcoming.csv",
                "http://www.info.sciverse.com/documents/files/content/docs/jnlimprint.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlnotrans.csv",
                "http://www.info.sciverse.com/techsupport/journals/freedomcoll.csv",
                "http://www.info.sciverse.com/techsupport/journals/sc2012.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlinexcl.csv",
                "http://www.info.sciverse.com/techsupport/journals/colhealthlife.csv",
                "http://www.info.sciverse.com/techsupport/journals/colphyseng.csv",
                "http://www.info.sciverse.com/techsupport/journals/colsocbeh.csv",
                "http://www.info.sciverse.com/techsupport/journals/corpedcoll.csv",
                "http://www.info.sciverse.com/techsupport/journals/govedcoll.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlcellpress.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlclinics.csv",
                "http://www.info.sciverse.com/techsupport/journals/doymed.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlemcitalian.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlemcspanish.csv",
                "http://www.info.sciverse.com/techsupport/journals/jnlfrench.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfagribio.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfagribiosup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfallergorheuim.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfanesthesio.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfbiogenmol.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfbiogenmolsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfbusmanacc.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfbusmanaccsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfcell.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfchemeng.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfchemengsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfclinneu.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfcompusci.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfcompuscisup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfdecsci.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfdentormed.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfearthsci.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfearthscisup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfeconfin.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfeconfinsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfenergy.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfengtech.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfenvsci.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfenvscisup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfforensicmed.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfgastro.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfgenmed.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfhemacardio.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfnucphys.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfnucphyssup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfimmunbio.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfimmunbiosup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfinorchem.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfinorchemsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmatsci.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmath.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmathsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmed_den.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmed_densup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmed_densup2.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfneuro.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfneurosup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfnursing.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfobgyn.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfoncology.csv",
                "http://www.info.sciverse.com/techsupport/journals/bforchem.csv",
                "http://www.info.sciverse.com/techsupport/journals/bforchemsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bforthoped.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfperiped.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfpharmatox.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfpharmatoxsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfphysanachem.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfphysanachemsup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfgenphys.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfgenphyssup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfpsychiatry.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfpsycho.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfpsychosup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfpubhealth.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfradioim.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfrespiratory.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfsocsci.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfsocscisup1.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfsurg.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfvet.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfufbiochem.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfufimm.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfufmed.csv",
                "http://www.info.sciverse.com/techsupport/journals/bfmissingissues.csv",
               ]
    def __init__(self, database=None):
        self.db = database
        publisher = db.query(Publisher).filter_by(name="ScienceDirect").first()
        if not publisher:
            raise Exception, "ScienceDirectScraper can't find its publisher"
        self.publisher = publisher
        self.journals = {}
    def scrape_journal_lists(self):
        self.download_csv()
        self.load_journals()
        for journal in self.journals:
            Journal.importer(journal, database=self.db)
    def download_csv(self):
        """downloads all csv files from sciencedirect
        if necessary? it really shouldn't just download everything all the time..."""
        sys.system("cd title_csv/")
        for url in self.csv_urls:
            sys.system("wget \""+url+"\"");
    def load_journals(self):
        self.read_active_journals()
        self.read_free_access()
    
        #this isn't worth csv parsing.. meh
        self.journals["02624079"] = {
            "current_title": "New Scientist",
                     "issn": "02624079",
                  "imprint": "Reed Business Information",
                   "active": True,
        }
    
        self.read_discontinued()
        self.read_transfers()
        self.read_removed()
        self.read_ppvaccess()
        self.read_corporate()
        self.add_journal_urls()
    
        return self.journals
    def export_journal_urls(self):
        journals = self.journals
        fh = open("journals.txt", "w")
        for journal_k in journals.keys():
            journal = journals[journal_k]
            fh.write(journal["url"] + "\n")
        fh.close()
    def add_journal_urls(self):
        journals = self.journals
        for key in journals.keys():
            issn = journals[key]["issn"]
            journals[key]["url"] = "http://www.sciencedirect.com/science/journal/" + issn
        return journals
    def read_corporate(self):
        journals = self.journals
        file_handler = codecs.open("title_csv/corpedcoll.csv", "r", encoding="latin1")
    
        #default is not in corporate package
        for key in journals.keys():
            journals[key]["in_corporate"] = False
    
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            full_title     = row[0]
            issn           = row[1]
            product_id     = row[2]
            status         = row[3]
            change_history = row[4]
    
            if issn in journals.keys():
                journals[issn]["in_corporate"] = True
            else:
                journals[issn] = {
                     "current_title": full_title,
                              "issn": issn,
                        "product_id": product_id,
                            "status": status,
                    "change_history": change_history,
                      "in_corporate": True,
                }
                print "Corporate - adding " + full_title.encode("utf-8") + " (" + issn.encode("utf-8") + ")"
    
        file_handler.close()
        return journals
    def read_active_journals():
        journals = self.journals
        file_handler = codecs.open("title_csv/jnlactive.csv", "r", encoding="latin1")
    
        rows = {}
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            current_title  = row[0]
            issn           = row[1]
            product_id     = row[2]
            change_history = row[3]
    
            print "processing: " + current_title.encode("utf-8") + " (" + issn.encode("utf-8") + ")"
    
            rows[issn] = {
                "current_title": current_title,
                         "issn": issn,
                   "product_id": product_id,
               "change_history": change_history,
                       "active": True,
            }
    
        file_handler.close()
    
        self.journals = rows
        return rows
    def read_free_access(self):
        journals = self.journals
        file_handler = codecs.open("title_csv/jnlfreeacc.csv", "r", encoding="latin1")
    
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            full_title         = row[0]
            issn               = row[1]
            product_id         = row[2]
            free_access_status = row[3]
    
            #this journal is not active
            if not issn in journals.keys():
                journals[issn] = {
                     "current_title": full_title,
                              "issn": issn,
                        "product_id": product_id,
                "free_access_status": free_access_status,
                }
            else:
                journals[issn]["free_access_status"] = free_access_status
    
                #curious if this ever snags anything..
                check_title_snag(journals[issn], full_title)
    
        file_handler.close()
        return journals
    def read_discontinued(self):
        journals = self.journals
        file_handler = codecs.open("title_csv/jnldiscontinued.csv", "r", encoding="latin1")
    
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            full_title      = row[0]
            issn            = row[1]
            product_id      = row[2]
            discontinued_at = row[3]
    
            if not issn in journals.keys():
                journals[issn] = {
                  "current_title": full_title,
                           "issn": issn,
                     "product_id": product_id,
                "discontinued_at": discontinued_at,
                         "status": "discontinued",
                }
            else:
                journals[issn]["discontinued_at"] = discontinued_at
                journals[issn]["status"]          = "discontinued"
    
                #curious if this ever snags anything..
                check_title_snag(journals[issn], full_title)
    
        file_handler.close()
        return journals
    def read_transfers(self):
        journals = self.journals
        file_handler = codecs.open("title_csv/jnltransfers.csv", "r", encoding="latin1")
    
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            full_title      = row[0]
            issn            = row[1]
            product_id      = row[2]
            new_publisher   = row[3]
            pubswitch_at    = row[4]
    
            if not issn in journals.keys():
                journals[issn] = {
                  "current_title": full_title,
                           "issn": issn,
                     "product_id": product_id,
                  "new_publisher": new_publisher,
                   "pubswitch_at": pubswitch_at,
                   "sciencedirect_has_paper": "probably",
                }
            else:
                journals[issn]["new_publisher"]           = new_publisher
                journals[issn]["pubswitch_at"]            = pubswitch_at
                journals[issn]["sciencedirect_has_paper"] = "probably"
    
                #curious if this ever snags anything..
                check_title_snag(journals[issn], full_title)
    
        file_handler.close()
        return journals
    def read_removed(self):
        journals = self.journals
        file_handler = codecs.open("title_csv/jnlremoved.csv", "r", encoding="latin1")
    
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            full_title      = row[0]
            new_publisher   = row[1]
            issn            = row[2]
            product_id      = row[3]
            status          = row[4]
            pubswitch_at    = row[5]
    
            if not issn in journals.keys():
                journals[issn] = {
                  "current_title": full_title,
                           "issn": issn,
                     "product_id": product_id,
                  "new_publisher": new_publisher,
                   "pubswitch_at": pubswitch_at,
                         "status": status,
                "sciencedirect_has_paper": False,
                }
            else:
                journals[issn]["new_publisher"]           = new_publisher
                journals[issn]["pubswitch_at"]            = pubswitch_at
                journals[issn]["sciencedirect_has_paper"] = False
    
                #curious if this ever snags anything..
                check_title_snag(journals[issn], full_title)
    
        file_handler.close()
        return journals
    def read_ppvaccess(self):
        journals = self.journals
        file_handler = codecs.open("title_csv/jnlnotrans.csv", "r", encoding="latin1")
    
        #by default let's grant this to everything?
        for key in journals.keys():
            journals[key]["ppv_access"] = True
    
        for row in unicode_csv_reader(file_handler, delimiter=",", quotechar="\""):
            if "Full Title" in row: continue
    
            full_title = row[0]
            issn       = row[1]
            product_id = row[2]
            status     = row[3]
    
            if issn in journals.keys():
                journals[issn]["ppv_access"] = False
                journals[issn]["status"]     = status
            else:
                assert Exception, "this shouldn't happen - hopefully Elsevier knows all of its journals :/"
    
        file_handler.close()
        return journals

class TestFixture:
    """loads up the same test data"""
    database = None
    first = None
    @classmethod
    def setUpClass(cls):
        """runs for each subclass, but don't repeat database creation"""
        cls.database = TestFixture.database
        if cls.database != None: return

        db = Database("sqlite:///:memory:") #or test.db ?
        db.create_tables()

        ut = School(name="University of Texas", url="www.utexas.edu")
        db.session.add(ut)

        sciencedirect = Publisher(name="ScienceDirect", url="www.sciencedirect.com")
        db.session.add(sciencedirect)
    
        ut_proxy = EzProxy(url="http://ezproxy.utexas.edu/", school=ut)
        db.session.add(ut_proxy)
    
        ut_auth = EzProxyLogin(ezproxy=ut_proxy, username="1134", password="9410491904")
        db.session.add(ut_auth)
    
        entry = EzProxyEntry(name="ScienceDirect", ezproxy=ut_proxy, publisher=sciencedirect)
        db.session.add(entry)
    
        #store it for later
        db.session.commit()
        cls.database = db
        TestFixture.database = db
    @classmethod
    def setUp(self):
        if self.first == None:
            self.first = self.database.session.query(self.cls).first()
    #this is why TestFixture shouldn't inherit unittest.TestCase directly
    def test_general(self):
        """a shared test across a few models"""
        db = self.database
        objects = db.session.query(self.cls).all()
        self.assertGreaterEqual(len(objects), 1)
class TestModelPublisher(TestFixture, unittest.TestCase):
    cls = Publisher
class TestModelSchool(TestFixture, unittest.TestCase):
    cls = School
    def test_proxies(self):
        self.assertGreaterEqual(len(list(self.first.proxies)), 1)
class TestModelEzProxy(TestFixture, unittest.TestCase):
    cls = EzProxy
    def test_relations(self):
        self.assertEqual(self.first, list(self.first.logins)[0].ezproxy)
        self.assertEqual(self.first, list(self.first.entries)[0].ezproxy)
    def test_in_school(self):
        self.assertIn(self.first, list(self.first.school.proxies))
class TestModelEzProxyLogin(TestFixture, unittest.TestCase):
    cls = EzProxyLogin
    def test_in_ezproxy(self):
        self.assertIn(self.first, list(self.first.ezproxy.logins))
class TestModelEzProxyEntry(TestFixture, unittest.TestCase):
    cls = EzProxyEntry
    def test_in_ezproxy(self):
        self.assertIn(self.first, list(self.first.ezproxy.entries))

class TestMetaTesting(unittest.TestCase):
    """test whether or not i am finding at least
    some of the tests in this file"""
    tests = []
    classes = []
    tested_names = []
    untested_names = []
    @classmethod
    def setUpClass(cls):
        if cls.tests in [None, []]:
            cls.tests = TestMetaTesting.find_tests()
        if cls.tested_names in [None, []]:
            cls.find_tested()
    @classmethod
    def report_untested(cls):
        """returns a report in a string about
        all untested methods in this file"""
        untested = cls.untested_names
        output = "NOT TESTED: " + str(untested) + "\n"
        output += "total not tested: " + str(len(untested))
        return output
    @staticmethod
    def run_tests():
        loader = unittest.TestLoader()
        suite = TestMetaTesting.load(loader, None, None)
        unittest.TextTestRunner(verbosity=2).run(suite)
        print TestMetaTesting.untested_names
    @staticmethod
    def find_tests():
        """finds classes that inherit from unittest.TestCase
        because i am too lazy to remember to add them to a 
        global list of tests for the suite runner"""
        classes = []
        clsmembers = inspect.getmembers(sys.modules[__name__], inspect.isclass)
        for (name, some_class) in clsmembers:
            if issubclass(some_class, unittest.TestCase):
                classes.append(some_class)
        return classes
    @staticmethod
    def load(loader, tests, pattern):
        """loads up a suite of tests"""
        suite = unittest.TestSuite()
        for test_class in TestMetaTesting.find_tests():
            tests = loader.loadTestsFromTestCase(test_class)
            suite.addTests(tests)
        return suite
    @classmethod
    def find_tested(cls):
        """finds all untested functions in this module
        by searching for method names in test case
        method names."""
        untested = []
        tested_funcs = []
        avoid_funcs = ["main", "run_tests", "run_main", "copy", "deepcopy"]
        #get a list of all classes in this module
        classes = inspect.getmembers(sys.modules[__name__], inspect.isclass)
        #for each class..
        for (name, klass) in classes:
            #only look at those that have tests
            if issubclass(klass, unittest.TestCase):
                #look at this class' methods
                funcs = inspect.getmembers(klass, inspect.ismethod)
                #for each method..
                for (name2, func) in funcs:
                    #store the ones that begin with test_
                    if "test_" in name2 and name2[0:5] == "test_":
                        tested_funcs.append([name2, func])
        #assemble a list of all test method names (test_x, test_y, ..)
        tested_names = [funcz[0] for funcz in tested_funcs]
        cls.tested_names = tested_names
        #now get a list of all functions in this module
        funcs = inspect.getmembers(sys.modules[__name__], inspect.isfunction)
        #for each function..
        for (name, func) in funcs:
            #we don't care about some of these
            if name in avoid_funcs: continue
            #skip functions beginning with _
            if name[0] == "_": continue
            #check if this function has a test named after it
            has_test = cls.has_test(name)
            if not has_test:
                untested.append(name)
        cls.untested_names = untested
        return untested
    @classmethod
    def has_test(cls, func_name, tested_names=None):
        """checks if there is a test dedicated to this function"""
        if tested_names == None:
            tested_names = cls.tested_names
        if tested_names == [] or tested_names == None:
            cls.find_tested_objects()        
        for name in tested_names:
            if name == func_name: return True
            if ("test_"+func_name) in name: return True
        return False
    def test_assemble_test_cases_count(self):
        "does assemble_test_cases find some tests?"
        self.failUnless(len(self.tests) > 0)
    def test_assemble_test_cases_inclusion(self):
        "is this class found by assemble_test_cases?"
        #i guess it would have to be for this to be running?
        self.failUnless(self.__class__ in self.tests)
    def test_assemble_test_cases_others(self):
        "test other inclusions for assemble_test_cases"
        self.failUnless(TestModelSchool in self.tests)
        self.failUnless(TestModelEzProxy in self.tests)
    def test_check_has_test(self):
        self.failUnless(self.__class__.has_test("beaver", ["test_beaver"]))
        self.failUnless(self.__class__.has_test("beaver", ["test_beaver_2"]))
        self.failIf(self.__class__.has_test("beaver_1", ["test_beaver"]))
    def test_find_untested_methods(self):
        untested = self.__class__.untested_names
        #the return type must be an iterable
        self.failUnless(hasattr(untested, "__iter__"))
        #.. basically, a list
        self.failUnless(isinstance(untested, list))

if __name__ == "__main__":
    TestMetaTesting.run_tests()
