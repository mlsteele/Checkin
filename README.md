Checkin Service
========

Simple checkin server and client.

Do you move computers around and want to know their IPs? Perhaps so that you can ssh into your forgotten files from abroad?

## Setup
Run the checkin server with

    coffee server.coffee -p 8213

For a different port, replace `8213` with anything else.

Then, on each client you want to track, add this (exceedingly long) entry to the clients crontab to run.

    * * * * * /usr/local/bin/node /usr/local/bin/coffee /Users/miles/code/checkin/client.coffee -n computer1 -h your.host.org -p 8213

You may want to turn down the frequency of the cron job.

To view a very ugly html representation your checkin information go to

    http://your.server.org:8213/

It should look something like this

    nickname  ip           date                                    utc           minutes since
    computer1 18.18.18.18  Wed Jul 24 2013 22:18:12 GMT-0400 (EDT) 1374718692184 1.40
    computer2 18.18.18.19  Wed Jul 24 2013 22:18:11 GMT-0400 (EDT) 1374718693x184 2.40

The checkin information will also be stored on the server in `checkins.json`.


## Issues
If the server crashes on start, delete the state store file `checkins.json` and try running the server again. The state was probably corrupted.
