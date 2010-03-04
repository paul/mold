require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Mold" do

  before do
    render("person_form.html.haml")
  end

  it 'should work' do
    output.should be_a(String)
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
