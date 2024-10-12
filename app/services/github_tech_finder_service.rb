class GithubTechFinderService
  ORG_LIMIT = 10

  def initialize(location, language = nil)
    @client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    @location = location
    @language = language
  end

  def find_tech_stacks
    orgs = fetch_orgs
    tech_stacks = orgs.map { |org| org_tech_stack(org.login) }
    filter_by_language(tech_stacks)
  end

  private

  def fetch_orgs
    results = @client.search_users("location:#{@location} type:organization sort:followers-desc", per_page: ORG_LIMIT)
    results.items.take(ORG_LIMIT)
  end

  def org_tech_stack(org_name)
    user = @client.user(org_name)
    repos = @client.repositories(org_name, query: { sort: 'updated', direction: 'desc', per_page: 20 })
    languages = count_languages(repos)

    {
      name: org_name,
      repository_count: user.public_repos,
      languages: languages,
      avatar: user.avatar_url,
      url: user.html_url
    }
  end

  def count_languages(repos)
    languages = repos.map(&:language).compact
    languages.each_with_object(Hash.new(0)) { |lang, counts| counts[lang] += 1 }
  end

  def filter_by_language(tech_stacks)
    return tech_stacks unless @language
    tech_stacks.select { |stack| stack[:languages].key?(@language) }
  end
end