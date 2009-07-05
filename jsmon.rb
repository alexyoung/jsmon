require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'active_support'
require 'config/db.rb'

class Service < ActiveRecord::Base
  validates_presence_of :code, :name
  validates_uniqueness_of :code
  validates_format_of :code, :with => /\A[a-zA-Z0-9_]*\Z/, :on => :update
  has_many :service_states, :dependent => :destroy

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
end

class ServiceState < ActiveRecord::Base
  validates_presence_of :service_id, :state
  validates_inclusion_of :state, :in => %w(success failure warning)
  belongs_to :service

  def self.newest_failing_states
    ServiceState.newest.find_all { |state| state.state == 'failure' }
  end

  def self.newest
    newest = Service.find(:all).collect do |service|
      ServiceState.find :first, :conditions => { :service_id => service.id }, :order => 'created_at DESC'
    end
    newest.compact
  end
end

helpers do
  def model_response(model)
    if model.valid?
      model.to_json
    else
      model.errors.to_json
    end
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
    attributes = {
      :name => values['name'],
      :description => values['description'],
      :code => values['code']
    }
    updated = false unless Service.find_by_code(code).update_attributes(attributes)
    Service.find_by_code(code).destroy if values['delete']
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
