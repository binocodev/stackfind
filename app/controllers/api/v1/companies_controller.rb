class Api::V1::CompaniesController < ApplicationController
  def search
    location = params[:location]
    results = GithubTechFinderService.new(ENV['GITHUB_ACCESS_TOKEN']).find_tech_stacks(location)
    render json: results
  end
end