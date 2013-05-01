A simple task that does the following:

- Query the enrollment status of a list of courses offered at the University of
Waterloo in the current term and see if you can enroll
- Send email notifications from you to yourself if you can enroll

## Prerequisite

- Ruby 1.9+

## Procedure

1. Clone this repo
2. Modify config.yaml as appropriate so your email credentials are correct
3. Modify courses.yaml for a list of courses of interest
4. Schedule to run this task periodically, e.g., through crontab on a machine:

        crontab -e

  Add a new line to the crontab file which should look like

        * * * * * cd ~/path_to_this_repo; /u4/s68zhang/local/bin/ruby query.rb

  The above configuration runs the task every minute.

## Student Linux Environment

The student linux machines at UW can be used to schedule this task, but you
need to install Ruby 1.9 as a user (since you don't have root access). All you
need to do is pass `--prefix=a_path_under_your_home_directory` to the autoconf
script when compiling Ruby from source.
