require 'pivotal-tracker'
require "highline/import"
require 'yaml'
require 'hashie/mash'

available_pt_proyects_ids = ['166935']

people =['Tim Labeeuw','Tony Hansmann', 'Alex Suraci','Sarah Chandler', 'Scott Andrews', 'rerek Collison',
         'Ramnivas Laddad', 'Maria Shaldybina','Mark Rushakoff', 'A.B.', 'Charles Lee', 'Jennifer Hickey',
         'Thomas Risberg', 'Matt Reider', 'Matthew Boedicker', 'Matthew Kocher', 'Max Brunsfeld',
         'Patrick Bozeman', 'Dmitriy Kalinin', 'Bob Nugmanov', 'David Sabeti', 'Kowshik Prakasam',
         'Nate Clark', 'Bleicke Petersen', 'Jesse Zhang', 'Jeff Li', 'James Bayer', 'Pieter Noordhuis',
          'Ryan Spore', 'Ryan Tang', 'Tim Lang', 'Gregg Van Hove', 'David Stevenson',
         'Scott Truitt', 'Onsi Fakhouri', 'Mark Kropf', 'Jeff Schnitzer'].sort!

components = ['bosh', 'cloud_controller_ng', 'dea_ng', 'health_manager', 'cf-message-bus']

commits = components.collect do |component|
  dir = "~/workspace/#{component}"

  `[ -d #{dir} ] && hub clone cloudfoundry/#{component} #{dir}`
  `cd #{dir}; git pull`
  log_output = `cd #{dir}; git log --author Alan --since yesterday --until today`
  next if log_output.empty?
  log_output.split('commit ').delete_if{ |m| m.empty? }.collect do |commit_log|
    sha1, story_id = commit_log.scan(/^(\w+).*\[.*#(.*)\]/m).flatten
    Hashie::Mash.new.tap do |commit|
      commit.component = component
      commit.sha1 = sha1
      commit.story_id = story_id
    end
  end
end.flatten!

who_i_worked_with_yesterday = choose do |menu|
  menu.header = 'PEOPLE'
  menu.prompt = "yesterday did you worked with any of this guys?"
  people.each do |person|
    menu.choice(person)
  end
end

PivotalTracker::Client.token('bonzofenix@gmail.com', 'malena04')

stories = available_pt_proyects_ids.collect do |id|
  proyect_stories = PivotalTracker::Project.find(id).stories.all(owned_by: who_i_worked_with_yesterday, current_state: ['accepted','started'])

  proyect_stories.collect do |s|
    Hashie::Mash.new.tap do |a_story|
      a_story.name = s.name
      a_story.accepted_at = s.accepted_at.nil? ? 'not finished yet' : s.accepted_at.strftime('%d/%m/%Y')
      a_story.state = s.current_state
      a_story.description = s.description
    end
  end
end.flatten

stories_i_worked_on = []
loop do
  selected = choose do |menu|
    menu.header = "STORIES - already selected: #{ stories_i_worked_on.collect(&:name) }"
    menu.prompt = "in which of this stories did you worked yesterday?"
    stories.each do |story|
      menu.choice story.name
    end
    menu.choice :quit
  end
  break if selected == :quit
  stories_i_worked_on << stories.select{ |s| s.name == selected }.first
  stories.delete_if{ |s| s.name == selected }
end



puts commits.to_yaml
puts stories_i_worked_on.to_yaml

mail = """
Hi guys,
yesterday i been working with #{who_i_worked_with_yesterday} on the following backend stories:
\t#{stories_i_worked_on.collect{ |s| "#{s.name}\n\t\t#{s.description}"}.join("\n\t")}
"""

mail+= " In case you want to check what with done this are the commits we made: " if commits
commits.each do |commit|
  puts '$'  
  mail+= " \nhttps://github.com/cloudfoundry/#{commit.component}/commit/#{commit.sha1} """ unless commits.nil?
end

puts '#' * 40
puts mail
puts '#' * 40



