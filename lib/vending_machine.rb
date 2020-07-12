require_relative './coin_bank'

class VendingMachine
	include CoinBank
	attr_accessor  :items, :item, :balance, :operative_coins, :bank_coins
	def initialize()
		@items = { 
			'001' => { name: 'Cocoa Cola', price: 5.99, units: 3 },
			'002' => { name: 'Banana Energy Bar', price: 19.99, units: 3 },
			'003' => { name: 'Office mouse', price: 18, units: 3 },
			'004' => { name: 'AA Batteries pack', price: 9.99, units: 3 }
		}
		# @item = nil
		# store all the vending machine money with all available types by increased order
		@bank_coins = {"0.25" => 5, "0.5" => 5, "1" => 5, "2" => 5, "5" => 5}
		@operative_sum = 0 # store transaction sum
		@operative_coins = Hash.new{0} # store transactions coins
	end

	def select_item( code = nil )
		@item = code ? items[code.to_s.rjust(3, '0')] : item # [code.to_sym]
		if item && in_stock?
			if @operative_sum > 0
				release_item if correct_sum_paid?
			else # only code added
				puts item[:name]
				"Price: #{item[:price]}"
			end
		else
			'Please add a valid item code'
		end
	end

	def insert_coin( paid )
		coin = paid.to_f
		if legal_coin? coin
			operative_coins[paid.to_s] += 1
			@operative_sum += coin
			if item
				select_item
			else
				"Inserted: #{get_coin(@operative_sum)}"
			end
		end
	end


	private

		def release_item
			coins_to_return, remaining_change = get_change
			if enough_change? remaining_change # give the item
				item[:units] -= 1
				# get real change # clear not supported coins
				final_change = balance - remaining_change
				# remove coins from bank for change
				return_coins_from_bank coins_to_return
				puts "1 item purchased"
				puts item[:name]
				if final_change != 0 # return change if exist
					puts "Your change is #{final_change}"
					return_coins_with_sound coins_to_return
				end
				reset_operative_status
				"Thank you for your purchase!"
			end
		end


		def legal_coin? coin
			if [0.25, 0.5, 1.0, 2.0, 5.0].include?(coin) # 25c 50c 1$ 2$ 5$
				true
			else
				return_coins_with_sound({coin => 1})
				raise 'The coin not recognized, machine accepts only (25c 50c 1$ 2$ 5$) coins'
			end
		end

		def in_stock?
			if item[:units] > 0
				true
			else
				return_coins_with_sound operative_coins
				puts "#{item[:name]} is out of stock"
				reset_operative_status
				raise "Would you like to buy another item?"
			end
		end

		def correct_sum_paid?
			price = item[:price].to_f
			@balance = ( @operative_sum - price ).round(2)
			if @operative_sum >= price
				true
			else
				puts "Product: #{item[:name]}"
				puts "Price: #{price}"
				puts "Inserted: #{get_coin(@operative_sum)}"
				raise "Outstanding balance: #{ get_coin balance }"
			end
		end

		def enough_change? remaining_change
			if remaining_change < 0.25 # not enough change to return
				true
			else
				return_coins_with_sound operative_coins
				return_coins_from_bank operative_coins
				reset_operative_status
				raise "Our apologies, the machine is out of charge"
			end
		end
end