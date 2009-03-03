require 'uri'
require 'httparty'
require 'builder'

class Webistrano
  include HTTParty
  format :xml
  headers({"content-type" => "application/xml"})
  
  def initialize(options = {})
    @options = {
      :url => nil,
      :project_id => nil,
      :stage_id => nil,
      :user => nil,
      :password => nil
    }.update(options)
    
    validate
    
    self.class.basic_auth @options[:user], @options[:password]
    self.class.base_uri @options[:url].dup
  end
  
  def deploy(task, comment)
    comment = "Github commit hook: " + comment
    self.class.post(construct_path, :body => build_deployment_xml(task, comment))
  end
  
  def build_deployment_xml(task, comment)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.deployment do |xml|
      xml.task task
      xml.description comment
    end
    xml.target!.to_s
  end
  

protected
  
  def construct_path
    path = @options[:url].dup.chomp('/')
    path += "/projects/#{@options[:project_id]}/stages/#{@options[:stage_id]}/deployments.xml"
    path
  end
  
  def validate
    @options.each do |k,v|
      raise ArgumentError, "Missing option #{k.to_s}" if v.nil?
    end
  end
  
end