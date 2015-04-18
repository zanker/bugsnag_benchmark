class TestData
  ALPHABET = ('a' .. 'z').to_a

  def self.random_str(size)
    size.times.map do
      ALPHABET.sample
    end.join
  end

  def self.generate
    test_data = {}
    # Setup basic meta data
    5.times do |i|
      inner = test_data["#{i}-test"] = {}
      10.times do |j|
        inner[j.to_s] = random_str(120)
      end
    end

    test_data['exceptions'] = 3.times.map do |i|
      {
        class: "Exception#{i}",
        message: random_str(60),
        trace: 60.times.map { random_str(100) }
      }
    end

    test_data
  end
end
