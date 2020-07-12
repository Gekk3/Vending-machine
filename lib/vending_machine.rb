class VendingMachine
	def initialize() 
	  #@items = items
		@items = { 
			'001' => { name: 'Cocoa Cola', price: 5.99, units: 3 },
			'001' => { name: 'Banana Energy Bar', price: 19.99, units: 3 },
			'001' => { name: 'Office mouse', price: 9.99, units: 3 },
			'001' => { name: 'AA Batteries pack', price: 9.99, units: 3 }
		}
		# store all the vending machine money with all available types by increased order
		@bank_coins = {"0.25" => 5, "0.5" => 5, "1" => 5, "2" => 5, "5" => 5}
		@operative_sum = 0 # store transaction sum
		@operative_coins = Hash.new{0} # store transactions coins
	end
	
	# pay 
	def vend(code, paid)
		item = items[code] # [code.to_sym]

		if item
			@operative_coins[paid.to_s] = paid
			return if out_of_stock? item
			return if illegal_sum? paid
			@operative_sum += paid
			price = item[:price].to_f
			balance = ( @operative_sum - price ).round(2)
			if @operative_sum >= price
				remaining_change = balance
				coins_to_return = {}
				# check bank from the biggest money type to lowest 
				@bank_coins.reverse_each do |type, num|
					if num != 0
						coin_value = type.to_f
						coins_count = (balance / coin_value).floor
						next if coins_count == 0
						# if coins left set count result else set all the coins
						coins_to_return[type] = coins_count < num ? coins_count : num
						remaining_change -= coin_value * coins_count
						break if remaining_change < 0.25 # lower than the lowest coin
					end
				end
				if remaining_change > 0.25 # not enough chabge to return
					return_coins_with_sound @operative_coins
					reset_temporary_bank
					"Our apologies, the machine is out of charge"
				else # give the item
					# get real change # clear not supported coins
					final_change = balance - remaining_change

					# remove coins from bank for change
					@bank_coins.merge!(coins_to_return) { |k, o, n| o - n }
					# move coins from temporary storage to the main coin bank
					@bank_coins.merge!(@operative_coins) { |k, o, n| o + n }
					
					reset_temporary_bank
					item[:units] -= 1
					puts "1 item purchased"
					puts item[:name]
					if final_change != 0 # return change if exist
						puts "Your change is #{final_change}"
						return_coins_with_sound coins_to_return
					end
					"Thank you for your purchase!"
				end
			else
				puts "Product: #{item[:name]}"
				puts "Price: #{price}"
				puts "Inserted: #{get_coin(@operative_sum)}"
				"Outstanding balance: #{ balance }"
			end
		else
			'Please add a valid item code'
		end
 	end
 
	private
 
 		attr_reader :items, :bank

 		def return_coins_with_sound coins
 			puts "Sound of falling coins:"
 			coins.each do |k, v|
				puts "#{ v } coins of #{ k }#{ get_coin(k) }"
			end
 		end

 		def get_coin type
 			"#{type}#{type.to_f < 1 ? 'C' : '$'}"
 		end

 		def reset_temporary_bank
 			@operative_coins.clear
 			@operative_sum = 0
 		end

 		def illegal_sum? paid
			unless %w{0.25 0.5 1 2 5}.include?(paid) # 25c 50c 1$ 2$ 5$ 
				return_coins_with_sound @operative_coins
				reset_temporary_bank
				return 'The coin not recognized, machine accepts only (25c 50c 1$ 2$ 5$) coins'
			end
 		end

 		def out_of_stock? item
 			if item.units == 0
				return_coins_with_sound @operative_coins
				reset_temporary_bank
 				puts "#{item.[:name]} is out of stock"
 				return "Would you like to buy another item?"
 			end
 		end

end