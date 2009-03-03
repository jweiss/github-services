require 'net/http'
require 'net/https'
require 'builder'

class Webistrano
  
  def initialize(options = {})
    @options = {
      :url => nil,
      :project_id => nil,
      :stage_id => nil,
      :user => nil,
      :password => nil
    }.update(options)
    
    validate
    
    @url = URI.parse(url)
    @path = construct_path
    @req = Net::HTTP::Post.new(@path)
    @req.basic_auth @options[:user], @options[:password]
  end
  
  def deploy(task, comment)
    comment = "Github commit hook. " + comment
    @req.set_form_data({
      'deployment'=> build_deployment_xml(task, comment)
    })
    @res = Net::HTTP.new(@url.host, @url.port).start {|http| http.request(@req) }
  end
  

protected
  
  def build_deployment_xml(task, comment)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.deployment do |xml|
      xml.task task
      xml.description comment
    end
    xml.target!.to_s
  end
  
  def construct_path
    path = @url.path.chomp('/')
    path += "/projects/#{@options[:project_id]}/stages/#{@options[:stage_id]}/deployments/create"
    path
  end
  
  def validate
    @options.each do |k,v|
      raise ArgumentError, "Missing option #{k.to_s}" if v.nil?
    end
  end
  
end