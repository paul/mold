
@person = { 
  :person => {
    :name   => nil,
    :spouse => {
      :name => nil
    },
    :children => [
      {
        :name  => nil,
        :age   => nil,
        :pets  => [
          {
            :name => nil,
            :species => nil,
          }
        ]
      }
    ]
  }
}

mold @person do |form|

  form.input :name

  form.nest :spouse do |spouse_form|
    spouse_form.input :name
  end

  form.nest :children do |child_form|

    child_form.input :name
    child_form.input :age, :type => :numeric

    child_form.nest :pets do |pet_form|
      pet_form.input :name
      pet_form.select :species, {:dog => "Dog", :cat => "Cat}
    end

  end
end
