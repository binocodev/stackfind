class GithubTechFinderService
  COMPANY_LIMIT = 5

  def initialize(access_token)
    @client = Octokit::Client.new(access_token: access_token)
  end

  def find_tech_stacks(location)
    companies = find_companies_by_location(location)
    companies.map { |company| analyze_company(company.login) }
  end

  private

  def find_companies_by_location(location)
    results = @client.search_users("location:#{location} type:organization", per_page: COMPANY_LIMIT)
    results.items.take(COMPANY_LIMIT)
  end

  def analyze_company(company_name)
    repos = @client.repositories(company_name)
    languages = repos.map(&:language).compact
    language_counts = languages.each_with_object(Hash.new(0)) { |lang, counts| counts[lang] += 1 }

    {
      name: company_name,
      repository_count: repos.count,
      languages: language_counts
    }
  end
end