service :webistrano do |data, payload|
  
  webistrano = Webistrano.new(
    :url => data['url'],
    :project_id => data['project_id'],
    :stage_id => data['stage_id'],
    :user => data['user'],
    :password => data['password']
  ) rescue throw(:halt, 400)
  
  task = data['task']
  
  if payload['commits'].last && payload['commits'].last['message'] =~ /^Merge/ && payload['commits'].last['message'] !~ /\sof\s/
    commits = payload['commits'][-1, 1]
  else
    commits = payload['commits']
  end
  
  description = "Deploying commits: \n" + commits.map{|c| "#{c['id']} - #{c['message']}\n"}
  
  webistrano.deploy(task, description)
end
