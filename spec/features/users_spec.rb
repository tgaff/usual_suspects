require 'rails_helper'

RSpec.feature "User sign-in" do
  background do
    # use this BDD syntax in feature specs
  end


  scenario "a sign-in dialog is present" do
    visit user_session_path

    expect(page).to have_button 'Log in'
    expect(page).to have_link 'Forgot your password?'
    expect(page).to have_field 'Email'
    expect(page).to have_field 'Password'
  end

  # note, we don't need JS here, but I want to see that poltergeist works in at least one test
  scenario "allows an existing user to sign-in" do
    user = FactoryGirl.create(:user)
    visit user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    # there's not much to test here until we have a page to redirect to on sign-in
    #expect(page).to have_field('Password', with: '')
    expect(page).to have_content 'Usual Suspects'
    expect(page).to have_content user.email
    expect(User.last.confirmed_at).to_not eq nil
  end

  scenario 'when the user is unconfirmed sign-in is prevented' do
    user = FactoryGirl.create(:unconfirmed_user)
    visit user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    # there's not much to test here until we have a page to redirect to on sign-in
    expect(page).to have_field('Password')
    expect(page).to have_no_content 'Welcome aboard'
    expect(User.last.confirmed_at).to eq nil
  end

end


RSpec.feature "User sign-up" do
  given(:user) { FactoryGirl.create(:user) }
  given(:new_email) { FactoryGirl.generate :email }

  scenario "has a sign-up form" do
    visit new_user_registration_path

    expect(page).to have_link 'Log in'
    expect(page).to have_field 'Email'
    expect(page).to have_field 'Password'
    expect(page).to have_field 'Password confirmation'
  end

  scenario "allows a user to create an account" do
    visit new_user_registration_path
    fill_in 'Email', with: new_email
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_on 'Sign up'
    expect(page).to have_content 'Usual Suspects'
    expect(User.last.email).to eq new_email
  end
end
