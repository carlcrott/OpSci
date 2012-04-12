# http://www.debian-administration.org/articles/56

*     *     *     *     *  Command to be executed
-     -     -     -     -
|     |     |     |     |
|     |     |     |     +----- Day of week (0-7)
|     |     |     +------- Month (1 - 12)
|     |     +--------- Day of month (1 - 31)
|     +----------- Hour (0 - 23)
+------------- Min (0 - 59)

Setup of Cron jobs:

$ cd ~/ && cd .. && cd .. && cd etc/
$ crontab -e # creates new crontab

# paste in:
0   *   *   *   * /bin/ls
# close nano w ctrl + x

# should see:
crontab: installing new crontab


# verify with
crontab -l







#publisher class + adapter

#class Publisher
#  attr_accessor :name, :url, :index, :rss

#  def initialize(name, url, index, rss)
#    @name = name
#    @url = url
#    @index = index
#  end

#end


#final_JSON_file << individual_journal_hashses



