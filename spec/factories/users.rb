FactoryBot.define do
  factory :user do
    id                    { 1 }
    nickname              { 'test1' }
    email                 { 'test@gmail.com' }
    password              { '123456' }
  end
end
