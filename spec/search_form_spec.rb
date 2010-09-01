require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Search Form" do

  before do
    render_haml('search_form')
  end

  it 'should work' do
    output.should have_tag(:form)
    puts output
  end

  it 'should use uppercase for the method attribute' do
    output.should have_tag(:form, :method => "GET")
  end

  it 'should have a label in the form' do
    output.should have_selector('form label')
  end

  it 'should have a label with the for attribute the same as the input id' do
    output.should have_tag(:label, :for => 'q')
  end

  it 'should have a label with the content specified' do
    output.should have_tag(:label, :content => "Search")
  end

end

