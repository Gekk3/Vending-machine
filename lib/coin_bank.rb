module CoinBank

  # def initialize()  
  # end
  private
	def save_temp_coins_to_bank
		bank_coins.merge!(@operative_coins) { |k, o, n| o + n }
	end

	def return_coins_from_bank( coins )
		bank_coins.merge!(coins) { |k, o, n| o - n }
	end


  	def return_coins_with_sound coins
		puts "** Sound of falling coins:"
		coins.each do |k, v|
			puts "** #{ v } coin#{'s' if v > 1 } of #{ get_coin(k) }"
		end
	end

	def get_coin type
		"#{type}#{type.to_f < 1 ? 'C' : '$'}"
	end

	def reset_operative_status
		@operative_coins.clear
		@operative_sum = 0
		@item = nil
	end

	def get_change
		remaining_change = balance
		coins_to_return = {}
		# move coins from temporary storage to the main coin bank
		# covers bug if by user temporary coins can save vendor purchase if not enough coins in the main bank
		save_temp_coins_to_bank
		# check bank from the biggest money type to lowest 
		bank_coins.reverse_each do |type, num|
			if num != 0
				coin_value = type.to_f
				coins_fit = (remaining_change / coin_value).floor
				next if coins_fit == 0
				# if coins left set count result else set all the coins
				coins_num = coins_fit < num ? coins_fit : num
				coins_to_return[type] = coins_num
				remaining_change -= coin_value * coins_num
				break if remaining_change < 0.25 # lower than the lowest coin
			end
		end
		return coins_to_return, remaining_change.round(2)
	end
 
end