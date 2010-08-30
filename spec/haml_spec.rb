require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Haml Template" do

  before do
    @bar = Bar.new
  end

  describe 'simple' do

    before do
      render_haml('simple_form')
    end

    it 'should work' do
      output.should have_tag('form')
      it_should_have_label_and_input(:name => "bar[name]",
                                     :id   => "bar_name")

    end

    it 'should have other block-level elements' do
      output.should have_tag('form p.test')
    end

  end

  describe 'nested' do
    before do
      render_haml('nested_form')
    end

    it 'should work' do
      output.should have_tag('form')
      it_should_have_label_and_input(:name => "bar[name]",
                                     :id   => "bar_name")

    end

    it 'should have other block-level elements' do
      output.should have_tag("form p.bar" , :content => @bar.name)
    end

    describe 'nest one' do

      it 'should have an inner element' do
        it_should_have_label_and_input(:name => "bar[address][street]",
                                       :id   => "bar_address_street")
      end

      it 'should have other block-level elements' do
        output.should have_tag("form p.street" , :content => @bar.address.street)
      end

    end

    describe 'nest many' do

      it 'should have an inner element' do
        @bar.beers.each do |beer|
          it_should_have_label_and_input(:name => "bar[beer][#{beer.id}][name]",
                                         :id   => "bar_beer_#{beer.id}_name")
        end
      end

      it 'should have other block-level elements' do
        @bar.beers.each do |beer|
          output.should have_tag("form p.beer" , :content => beer.name)
        end
      end


    end

  end

end
