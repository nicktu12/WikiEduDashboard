require 'rails_helper'

describe 'Instructor users', type: :feature, js: true do
  before do
    include Devise::TestHelpers, type: :feature
    Capybara.current_driver = :selenium
  end

  before :each do
    user = create(:user,
                  id: 100,
                  wiki_id: 'Professor Sage',
                  wiki_token: 'foo',
                  wiki_secret: 'bar')

    create(:user,
           id: 101,
           wiki_id: 'Student A')
    create(:user,
           id: 102,
           wiki_id: 'Student B')
    create(:course,
           id: 10001,
           title: 'My Active Course',
           school: 'University',
           term: 'Term',
           slug: 'University/Course_(Term)',
           submitted: 1,
           listed: true,
           passcode: 'passcode',
           start: '2015-01-01'.to_date,
           end: '2020-01-01'.to_date)
    create(:courses_user,
           id: 1,
           user_id: 100,
           course_id: 10001,
           role: 1)
    create(:courses_user,
           id: 2,
           user_id: 101,
           course_id: 10001,
           role: 0)
    create(:courses_user,
           id: 3,
           user_id: 102,
           course_id: 10001,
           role: 0)
    create(:cohort,
           id: 1,
           title: 'Fall 2015')
    create(:cohorts_course,
           cohort_id: 1,
           course_id: 10001)

    login_as(user, scope: :user)
  end

  describe 'visiting the students page' do
    it 'should be able to remove students' do
      stub_oauth_edit
      visit "/courses/#{Course.first.slug}/students"
      sleep 1

      # Click the Enrollment button
      page.all('button.dark')[1].click
      sleep 1
      # Remove a user
      page.all('button.border.plus')[1].click
      sleep 1
      page.driver.browser.switch_to.alert.accept

      visit "/courses/#{Course.first.slug}/students"
      expect(page).to have_content 'Student A'
      expect(page).not_to have_content 'Student B'
    end

    # FIXME: As with the similar tests for assigning articles in the student
    # role spec, this breaks on travis-ci.org even though it passes locally.
    # it 'should be able to assign articles' do
    #   stub_oauth_edit
    #   visit "/courses/#{Course.first.slug}/students"
    #   sleep 1
    #
    #   # Assign an article
    #   page.all('button.dark')[0].click
    #   page.all('button.border')[0].click
    #   page.first('input').set('Article 1')
    #   page.all('button.border')[1].click
    #   page.driver.browser.switch_to.alert.accept
    #   page.first('button.border.dark.plus').click
    #   sleep 1
    #
    #   # Assign a review
    #   page.all('button.border')[1].click
    #   page.first('input').set('Article 2')
    #   page.all('button.border')[2].click
    #   page.driver.browser.switch_to.alert.accept
    #   page.all('button.border.dark.plus')[0].click
    #
    #   # Save these assignments
    #   page.all('button.dark')[0].click
    #   expect(page).to have_content 'Article 1'
    #   expect(page).to have_content 'Article 2'
    # end

    it 'should be able to notify untrained users' do
      stub_oauth_edit
      visit "/courses/#{Course.first.slug}/students"
      sleep 1

      # Notify untrained users
      page.first('button.notify_untrained').click
      page.driver.browser.switch_to.alert.accept
      sleep 1
    end
  end

  after do
    logout
    Capybara.use_default_driver
  end
end
