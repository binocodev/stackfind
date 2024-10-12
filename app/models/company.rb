class Company < ApplicationRecord
  def self.search_by_tech_stack(query)
    where("tech_stack ILIKE ?", "%#{query}%")
  end
end