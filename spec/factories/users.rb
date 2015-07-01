FactoryGirl.define do
  factory :user do
    email "g@g.com"
    password "123123456"
    password_confirmation { "123123456" }
  end
end
