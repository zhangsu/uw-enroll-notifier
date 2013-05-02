# Can run this script in a crontab.

require 'net/http'
require 'net/smtp'
require 'json'
require 'yaml'
require 'time'

config = YAML.load_file('config.yaml')
name = config['name']
sender = config['email']
recipients = [sender]
userid = sender
password = config['password']

smtp = Net::SMTP.new(config['smtp']['host'], config['smtp']['port'])
smtp.enable_starttls

# Searches any string containing "cancel" and ignores casing. Some sections are
# cancelled but the "IsCancelled" field returned by the API is still "0".
# However, there is usually a "cancel" text somewhere in the nested structure.
def recursive_searcher(iterator = :each)
  -> do
    send iterator do |value|
      if value.is_a? Enumerable
        return true if value.includes_cancel_text?
      else
        return true if value =~ /cancel/i
      end
    end
    false
  end
end

class Array
  define_method :includes_cancel_text?, recursive_searcher
end

class Hash
  define_method :includes_cancel_text?, recursive_searcher(:each_value)
end

courses = YAML.load_file('courses.yaml')
domain = (sender =~ /.+@(.+)/; $1)

smtp.start(domain, userid, password, :login) do
  open('result.log', 'a') do |log|
    log.puts Time.now
    for course in courses
      # Call API to get course schedule info.
      querystring = URI.encode_www_form(
        key: '9d539b2f90841c43c6544de7bf4afc36',
        service: 'Schedule',
        q: course.strip
      )
      uri = URI("http://api.uwaterloo.ca/public/v1/?#{querystring}")
      response = JSON.parse(Net::HTTP.get(uri))['response']
      data = response['data']

      next unless data['result']

      # Process each section.
      for d in data['result']
        course_code = d['Subject'] + d['Number']
        section = d['Section']
        capacity = d['EnrollmentTotal'] + '/' + d['EnrollmentCap']
        log << sprintf("%10s %8s enroll %8s\n", course_code, section, capacity)

        # Skip cancelled section.
        next if d['IsCancelled'] == '1' or d.includes_cancel_text?

        # Send notification if the enrollment is below capacity.
        if d['EnrollmentTotal'].to_i < d['EnrollmentCap'].to_i
            smtp.send_mail <<EOM, sender, recipients
From: #{name} <#{sender}>
To: #{name} <#{sender}>
Subject: #{course_code} #{section} is Below Enrollment Capacity!
Date: #{Time.now.rfc2822}

Capacity: #{capacity}
End of message.
EOM
        end
      end
    end
    log.puts '============'
  end
end
