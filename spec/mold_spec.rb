require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Mold" do

  before do
    render {
      mold :person do |f|
        f.label :name
        f.input :name
      end
    }
  end

  it "should have a form" do
    output.should have_tag(:form)
  end

  it "should have a label and input" do
    it_should_have_label_and_input(:name => "person[name]",
                                   :id   => "person_name")
  end

  describe 'form name' do

    class NamedPerson # Works like ActiveModel
      def self.name
        "person"
      end
    end

    class Person

    end

    [
      "person",
      :person,
      NamedPerson.new,
      Person.new
    ].each do |person|
      it "should work with a #{person.class}" do
        @person = person

        render {
          mold @person do |f|
            f.label :name
            f.input :name
          end
        }

        output.should have_tag(:form, :name => "person")
      end

    end

  end

end
