class Api::V1::CompaniesController < ApplicationController
  def search
    location = params[:location]
    language = params[:language]

    service = GithubTechFinderService.new(location, language)
    results = service.find_tech_stacks

    render json: results
  end
end