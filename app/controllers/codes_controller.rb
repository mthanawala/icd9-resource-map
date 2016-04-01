class CodesController < ApplicationController

  def index
    render :xml => Code.all.to_xml
  end

  def show
    code = Code.find_by_code(params[:id])
    render :xml => (code.nil? ? Code.new.to_xml : code.to_xml)
  end
end
