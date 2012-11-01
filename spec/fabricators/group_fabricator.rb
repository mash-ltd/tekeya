Fabricator(:group) do
  name { Faker::Name.name }
  owner { Fabricate(:user) }
end