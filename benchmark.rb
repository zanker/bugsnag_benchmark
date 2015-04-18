require 'benchmark'
require 'set'
require './test_data.rb'
require './cleaner_new.rb'
require './cleaner_old.rb'
require './cleaner_micro.rb'

test_data = TestData.generate
filter_keys = ['1', '2', '3', '4', '5']

Benchmark.bm do |x|
  x.report("New Cleaner") do
    1_000.times do
      CleanerNew.cleanup_obj(test_data, filter_keys)
    end
  end

  x.report("Micro Cleaner") do
    1_000.times do
      CleanerMicro.cleanup_obj(test_data, filter_keys)
    end
  end

  x.report("Old Cleaner") do
    1_000.times do
      CleanerOld.cleanup_obj(test_data, filter_keys)
    end
  end
end
