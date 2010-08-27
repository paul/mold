require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Mold" do

  class Bar
    def name
      "Melody Inn"
    end

    def beers
      [
        Beer.new(1, "Neversummer Ale"),
        Beer.new(2, "Dale's Pale Ale")
      ]
    end

    def address
      Address.new
    end
  end

  class Beer
    attr_accessor :id, :name

    def initialize(id, name)
      @id, @name = id, name
    end
  end

  class Address
    def street
      "N Illinois St"
    end
  end

  describe "from an object" do

    before do
      @bar = Bar.new

      render {
        mold @bar do |form|
          form.input :name
        end
      }
    end

    it 'should have a text input' do
      output.should have_tag(:input, :name => "bar[name]", :value => @bar.name)
    end

    describe 'nest one' do
      before do
        render {
          mold @bar do |form|
            form.nest(@bar.address) do |address_form, address|
              "<p>" + address.street + "</p>" +
              address_form.input(:street)
            end
          end
        }
      end

      it 'should have a text input' do
        output.should have_tag(:input, :name => "bar[address][street]", :value => @bar.address.street)
      end

      it 'should yield the object to the block as the second argument' do
        output.should have_tag(:p, :content => @bar.address.street)
      end

    end

    describe 'nest many' do
      before do
        render{
          mold @bar do |form|
            form.nest_many(@bar.beers) do |beer_form, beer|
              "<p>" + beer.name + "</p>" +
              beer_form.input(:name)
            end
          end
        }
      end

      it 'should have a text input' do
        @bar.beers.each do |beer|
          output.should have_tag(:input, :name => "bar[beer][#{beer.id}][name]", :value => beer.name)
        end
      end

      it 'should yield the object to the block as the second argument' do
        @bar.beers.each do |beer|
          output.should have_tag(:p, :content => beer.name)
        end
      end


    end
  end

end

