A simple script designed to be run on the Linux student environment. It does
the following:

- Query the enrollment status of a list of courses in the current term and see
if you can enroll
- Send notifications when you can using your own email

# Prerequisite

- Ruby 1.9+. Ruby 1.9+ can be installed under your home drive (user install)
in the student environment.

# Procedure

1. Clone this repo on your student machine.
2. Modify config.yaml as appropriate so your email credentials are correct.
3. Modify courses.yaml for a list of courses of interest
4. Run this script periodically, e.g., through crontab on one of the machines:

        crontab -e

  Add a new line to the crontab file which should look like

        * * * * * cd ~/path_to_this_repo; /u4/s68zhang/local/bin/ruby query.rb

  Which runs every minute.
