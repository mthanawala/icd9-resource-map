class CodesController < ApplicationController

  def index
    render :xml => Code.all.to_xml
  end

  def show
    code = Code.find_by_code(params[:id])
    if code.nil?
      render :xml => Code.new.to_xml
    else
      code.url ||= code.computed_url
      code.title ||= code.computed_title
      code.summary ||= code.computed_summary
      code.save!
      render :xml => code.to_xml
    end
  end
end
