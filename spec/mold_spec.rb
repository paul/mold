require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Mold" do

  before do
    render {
      <<-HAML.gsub(/^ {8}/, '')
        = mold :person do |form|
          = form.label :name
          = form.input :name
      HAML
    }
  end

  it "should have a form" do
    output.should have_tag(:form)
  end

  it "should have a label and input" do
    it_should_have_label_and_input(:name => "person[name]",
                                   :id   => "person_name")
  end


end
