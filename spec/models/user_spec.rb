require 'rails_helper'

RSpec.describe User, type: :model do

    subject(:user) { FactoryGirl.create(:user) }

    it { should respond_to(:email) }
    it { should respond_to(:password) }

    it { should be_valid }
end
