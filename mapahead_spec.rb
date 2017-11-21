require 'rspec'
require_relative 'mapahead.rb'
require 'pry'

Thread.abort_on_exception = true

describe MapAhead do

  describe 'map against stream (:stream_map)' do

    let(:enum_length) { rand(10..20) }
    let(:source_enum) { get_enumerable(enum_length) }

    it 'calls block for each element in enumerable' do
      calls = 0
      subject.stream_map(source_enum) { calls += 1 }.to_a
      expect(calls).to eq enum_length
    end

    it 'returns enumerable with same count as source enum' do
      expect(subject.stream_map(source_enum){}.count).to eq enum_length
    end

    it 'returns enum which contains result of calling block for each element in source enum' do
      random_array = Array.new(enum_length) { rand(100) }
      expected_array = random_array.map { |i| i + 1 }
      counting_enum = Enumerator.new do |y|
        while r = random_array.shift
          y << r
        end
      end
      r = subject.stream_map(counting_enum) { |i| i += 1 }
      expect(r.to_a).to include(*expected_array)
    end

    context 'work ahead argument provided' do
      it 'does work in parallel' do
        working = false
        collisions = []
        subject.stream_map(source_enum, 2) do
          collisions << 1 if working
          working = true
          sleep 0.1
          working = false
        end.to_a
        expect(collisions.length).to be > 0
      end

      it 'has more than 1 block called in parallel' do
        lock = Mutex.new
        max_in_flight = 0
        in_flight = 0
        subject.stream_map(source_enum, 2) do
          lock.synchronize {  in_flight += 1 }
          sleep 0.1
          lock.synchronize {
            max_in_flight = [in_flight, max_in_flight].max
            in_flight -= 1
          }
        end.to_a
        expect(max_in_flight).to be > 1
      end

      it 'never has more blocks called in parallel than work ahead arg' do
        max_in_flight = 0
        in_flight = 0
        subject.stream_map(source_enum, 2) do
          in_flight += 1
          sleep 0.1
          max_in_flight = [in_flight, max_in_flight].max
          in_flight -= 1
        end
        expect(max_in_flight).to be <= 2
      end

      it 'does not read ahead more than passed work ahead' do
        count_read = 0
        count_worked = 0
        diff_max = 0
        custom_enum = Enumerator.new do |y|
          enum_length.times do
            puts "adding"
            y << count_read += 1
          end
        end
        subject.stream_map(custom_enum, 2) do |i|
          sleep 0.1
          count_worked += 1
          diff_max = [diff_max, count_read - count_worked].max
          puts "counts: #{count_read} :: #{count_worked}"
        end.to_a
        expect(diff_max).to eq 2
      end
    end

    context 'no block is provided' do
      it 'returns source enumerable' do
        expect(subject.stream_map(source_enum)).to eq source_enum
      end
    end

    context 'given an enumerable with zero elements' do
      let(:enum_length) { 0 }
      it 'returns an enumerable without elements' do
        expect(subject.stream_map(source_enum).count).to eq 0
      end
    end
  end

end

def get_enumerable(length=0)
  Enumerator.new { |y| length.times { |i| y << i } }
end
