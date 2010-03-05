require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Nested" do

  describe "Single" do

    before do
      render {
        <<-HAML.gsub(/^ {10}/, '')
          = mold :person do |form|
            = form.nest :spouse do |spouse_form|
              = spouse_form.label :name
              = spouse_form.input :name
        HAML
      }
    end

    it "should have a label and input" do
      it_should_have_label_and_input(:name => "person[spouse][name]",
                                     :id   => "person_spouse_name")
    end

  end

  describe "Many" do
    before do
      render {
        <<-HAML.gsub(/^ {10}/, '')
          = mold :person do |form|
            = form.nest_many :children do |child_form|
              = child_form.label :name
              = child_form.input :name
        HAML
      }
    end

    it "should have a label and input" do
      it_should_have_label_and_input(:name => "person[children][][name]",
                                     :id   => "person_children_name")
    end
  end

  describe "Three-deep" do

    before do
      render {
        <<-HAML.gsub(/^ {10}/, '')
          = mold :person do |form|
            = form.nest_many :children do |child_form|
              = child_form.nest_many :pets do |pet_form|
                = pet_form.label :name
                = pet_form.input :name
        HAML
      }
    end

    it "should have a label and input" do
      it_should_have_label_and_input(:name => "person[children][][pets][][name]",
                                     :id   => "person_children_pets_name")
    end

  end

end

