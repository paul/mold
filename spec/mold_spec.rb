require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Mold" do

  before do
    @template = Tilt::HamlTemplate.new(File.expand_path('fixtures/person_form.html.haml', File.dirname(__FILE__)))
    @output = @template.render(@context)
  end

  it 'should work' do
    @output.should be_a(String)
  end

  it 'should have a top-level name' do
    @output.should have_tag(:input, :name => "person[name]")
  end

  it 'should have a top-level id' do
    @output.should have_tag(:input, :id => "person_name")
  end



end
