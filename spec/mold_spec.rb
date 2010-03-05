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

  it 'should have a top-level name' do
    output.should have_tag(:input, :name => "person[name]")
  end

  it 'should have a top-level id' do
    output.should have_tag(:input, :id => "person_name")
  end

  it 'should have a label' do
    output.should have_tag(:label, :for => "person_name")
  end



end
