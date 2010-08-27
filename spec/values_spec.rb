require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Mold with values" do

  describe "text fields" do
    before do
      render{
        mold :person do |form|
          form.input :name, :value => "Paul"
        end
      }
    end

    it "should set value attribute on text fields" do
      output.should have_tag(:input, :value => "Paul")
    end
  end

  describe "textarea fields" do
    before do
      render{
        mold :person do |form|
          form.textarea :name, :value => "Paul"
        end
      }
    end

    it "should set value as content in textarea fields" do
      output.should have_tag(:textarea, :content => "Paul")
    end
  end

  describe "select fields" do
    before do
      render{
        mold :person do |form|
          form.select :name, {:bob => "Bob", :paul => "Paul"}, :value => :paul
        end
      }
    end

    it "should set the option as selected" do
      output.should have_tag(:option, :value => "paul", :selected => "selected")
      output.should_not have_tag(:option, :value => "bob", :selected => "selected")
    end
  end
end
