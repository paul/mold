module Spec::MoldObjects

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

end

