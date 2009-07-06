require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'active_support'
require 'config/db.rb'

class Service < ActiveRecord::Base
  validates_presence_of :code, :name
  validates_uniqueness_of :code
  validates_format_of :code, :with => /\A[a-zA-Z0-9_]*\Z/, :on => :update
  has_many :service_states, :dependent => :destroy, :order => 'created_at DESC'

  before_validation_on_create :set_unique_code

  def self.failing_services
    ServiceState.newest_failing_states.collect { |state| state.service }
  end

  def random_hash
    ActiveSupport::SecureRandom.base64(4).gsub("/","_").gsub(/=+$/,"")
  end

  def set_unique_code
    write_attribute :code, self.random_hash
  end

  def hide_failure
    newest_failing = service_states.find(:first, :conditions => { 'state' => 'failure', 'hidden' => false })
    if newest_failing
      newest_failing.update_attribute :hidden, true
    end
  end
end

class ServiceState < ActiveRecord::Base
  validates_presence_of :service_id, :state
  validates_inclusion_of :state, :in => %w(success failure warning)
  belongs_to :service

  def self.newest_failing_states
    ServiceState.newest.find_all { |state| state.state == 'failure' and !state.hidden? }
  end

  def self.newest
    newest = Service.find(:all).collect do |service|
      ServiceState.find :first, :conditions => { :service_id => service.id }, :order => 'created_at DESC'
    end
    newest.compact
  end
end

helpers do
  def display_failing_services(services)
    links = services.collect do |service|
      "<a class=\"edit_service\" href=\"#\" id=\"service_#{service.code}\">#{service.name}</a>"
    end
    links.join(', ')
  end
end

get '/service/:code' do |code|
  Service.find_by_code(code).to_json
end

get '/service/:code/:state' do |code, state|
  service = Service.find_by_code code

  if service.nil?
    raise Sinatra::NotFound
  end

  state = ServiceState.create :service_id => service.id,
                              :state => state,
                              :exit_code => params[:exit_code],
                              :info => params[:info]
  state.to_json
end

post '/service' do
  service = Service.create :description => params[:description], :name => params[:name]
  redirect "/?created=#{service.valid?}#manage"
end

post '/services/update' do
  updated = true
  params['services'].each do |code, values|
    service = Service.find_by_code(code)
    attributes = {
      :name => values['name'],
      :description => values['description'],
      :code => values['code']
    }
    updated = false unless service.update_attributes(attributes)
    service.destroy if values['delete']

    if values['hidden'] == 'true'
      service.hide_failure
    end
  end

  redirect "/?updated=#{updated}#manage"
end

get '/' do
  @statuses = ServiceState.find :all,
                                :conditions => ['state != ?', 'success'],
                                :limit => 50,
                                :order => 'created_at DESC'
  @failing_services = Service.failing_services
  @services = Service.find :all
  erb :index, :layout => :layout
end
