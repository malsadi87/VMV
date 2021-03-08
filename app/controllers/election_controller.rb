class ElectionController < ApplicationController
  def index
    require 'json'
    json = File.read('public/files/finished-elections.json')
    @completed_elections = JSON.parse(json)
  end

  def view
    @id = params[:id]
  end

  def uploads
    require 'csv'
    id =  params[:id]
    file = params[:file]
    url = 'public/files/completed/'+id+'/'+file+'.csv'
    @fileContent = CSV.parse(File.read(url), headers: true)
  end

  def record 
    @row = params[:row].split(",")
    puts @row.length
    @headers = params[:headers].split(",")
    puts @headers
  end

  def truncate(string)
    string.length > 30 ? "#{string[0...8]}..." : string
  end
end
