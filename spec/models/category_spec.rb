# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id             :integer          not null, primary key
#  wiki_id        :integer
#  article_titles :text(16777215)
#  name           :string(255)
#  depth          :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe '.refresh_categories_for' do
    let(:category) { create(:category, name: 'Homo sapiens fossils') }
    let(:course) { create(:course) }
    let!(:article) { create(:article, title: 'Manot_1') }
    before do
      course.categories << category
    end

    it 'updates article titles for categories associated with courses' do
      expect(Category.last.article_titles).to be_empty

      VCR.use_cassette 'categories' do
        Category.refresh_categories_for(Course.all)
        expect(Category.last.article_titles).not_to be_empty
        expect(Category.last.article_ids).to include(article.id)
      end
    end
  end
end
