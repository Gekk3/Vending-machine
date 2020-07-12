require_relative '../lib/vending_machine'

RSpec.describe VendingMachine do
	
	context "#select_item" do

		let(:machine){ VendingMachine.new() }

		it 'Should return product and price' do
			expect(machine.select_item('1')).to eql "Price: 5.99"
			expect(machine.select_item(1)).to eql "Price: 5.99"
		end

		it 'Should replace selected item' do
			machine.select_item('1')
			machine.select_item('2')
			expect(machine.item[:name]).to eql 'Banana Energy Bar'
		end

		it 'Should return invalid item code' do
			expect(machine.select_item('5')).to eql 'Please add a valid item code'
			expect(machine.select_item(5)).to eql 'Please add a valid item code'
			expect(machine.select_item()).to eql 'Please add a valid item code'
		end

		it '#in_stock? Should be out of stock v1 - light' do
			machine.items['001'] = { name: 'Cocoa Cola', price: 5.99, units: 0 }
			expect{machine.select_item(1)}.to raise_error("Would you like to buy another item?")
		end

		it '#in_stock? Should be out of stock v2 - buy all' do
			3.times do # empty stock
				2.times do
					machine.insert_coin(5)
				end
				machine.select_item(1)
			end
			expect{machine.select_item(1)}.to raise_error("Would you like to buy another item?")
		end
	end

	context "#insert_coin - insert_coin" do

		let(:machine){ VendingMachine.new() }

		it 'Should return not amount' do
			expect(machine.insert_coin('0.25')).to eql "Inserted: 0.25C"
			expect(machine.insert_coin(0.25)).to eql "Inserted: 0.5C"
			expect(machine.insert_coin("1")).to eql "Inserted: 1.5$"
			expect(machine.insert_coin(1)).to eql "Inserted: 2.5$"
		end

		it 'Should return not recognized' do
			expect{machine.insert_coin('3')}.to raise_error 'The coin not recognized, machine accepts only (25c 50c 1$ 2$ 5$) coins'
			expect{machine.insert_coin(3)}.to raise_error 'The coin not recognized, machine accepts only (25c 50c 1$ 2$ 5$) coins'
			expect{machine.insert_coin()}.to raise_error(ArgumentError)
		end

		it 'Buy item 1' do
			machine.select_item(1)
			expect{machine.insert_coin(5)}.to raise_error "Outstanding balance: -0.99C"
			expect(machine.insert_coin(1)).to eql "Thank you for your purchase!"
		end

		it 'Buy item 1 - with no change ' do
			machine.bank_coins = {"0.25" => 5, "0.5" => 5, "1" => 0, "2" => 0, "5" => 0}
			machine.insert_coin(5)
			machine.insert_coin(5)
			expect{machine.select_item(1)}.to raise_error "Our apologies, the machine is out of charge"
		end
	end

	context "#get_change - private method - get right change & bank" do
		let(:machine){ VendingMachine.new() }
		it 'Buy item 1 with 10.25$/5.99' do
			price = 5.99
			machine.operative_coins = {"5" => 2, "0.25" => 1}
			operative_sum = 10.25
			machine.balance = ( operative_sum  - price ).round(2)
			expect(machine.send(:get_change)).to eql [{"2" => 2, "0.25" => 1}, 0.01]
			expect(machine.send(:return_coins_from_bank, {"2" => 2, "0.25" => 1})).to eq("0.25" => 5, "0.5" => 5, "1" => 5, "2" => 3, "5" => 7)
			expect(machine.bank_coins).to eq("0.25" => 5, "0.5" => 5, "1" => 5, "2" => 3, "5" => 7)
		end

		it 'Buy item 2 with 20$/19.99' do
			price = 19.90
			operative_sum = 20
			machine.operative_coins = {"5" => 4}
			machine.balance = ( operative_sum  - price ).round(2)
			expect(machine.send(:get_change)).to eql [{}, 0.1]
			expect(machine.send(:return_coins_from_bank, {})).to eq("0.25" => 5, "0.5" => 5, "1" => 5, "2" => 5, "5" => 9)
			expect(machine.bank_coins).to eq("0.25" => 5, "0.5" => 5, "1" => 5, "2" => 5, "5" => 9)
		end
		it 'Buy item 3 20.50$/18' do
			price = 18
			operative_sum = 20.50
			machine.operative_coins = {"5" => 4, '0.5' => 1}
			machine.balance = ( operative_sum  - price ).round(2)
			expect(machine.send(:get_change)).to eql [{"0.5" => 1, "2" => 1}, 0.00]
			expect(machine.send(:return_coins_from_bank, {"0.5" => 1, "2" => 1})).to eq("0.25" => 5, "0.5" => 5, "1" => 5, "2" => 4, "5" => 9)
			expect(machine.bank_coins).to eq("0.25" => 5, "0.5" => 5, "1" => 5, "2" => 4, "5" => 9)
		end
	end
end