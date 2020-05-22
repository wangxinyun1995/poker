class PokerGame < ApplicationRecord
  SORT = {
   'A' => 1,
   '1' => 2,
   '2' => 3,
   '3' => 4,
   '4' => 5,
   '5' => 6,
   '6' => 7,
   '7' => 8,
   '8' => 9,
   '9' => 10,
   '0' => 11,
   'J' => 12,
   'Q' => 13,
   'K' => 14
  }
  COLOR = {
    'S' => 4,
    'H' => 3,
    'C' => 2,
    'D' => 1
  }
  def record_init(record)
    # 处理获取到的发牌记录,结果eg: {"C_10"=>9, "D_8"=>7, "D_10"=>9, "S_8"=>7, "D_3"=>2} 
    # 'C_10'中'C'记录的是花色, spade(S) > heart(H) > club(C) > diamond(D), 数字根据PokerGame::SORT记录顺序大小
    arrs = record.gsub('10', '0').split('')
		j = ''
    record_hash = {}
		arrs.each do |arr|
			if ['S', 'H', 'C', 'D'].include?(arr)
				j = arr
				next
			end
			h_key = j + '_' + PokerGame::SORT[arr].to_s
			if ['J', 'Q', 'K', '0'].include?(arr)
				record_hash[h_key] = 10
      else   
				record_hash[h_key] = arr == 'A' ? 1 : arr.to_i
			end
		end
    return record_hash
	end
	
  def get_score(record_list)
    # 获取分数的思路是如果三张牌之和能被10整除, 
    # 那么余下的两张牌之和除以10的余数等于五张牌之和除以10的余数,任意两张牌之和在(0 < sum =< 20)
		remainder = (record_list.values.sum)%10
    return 10 if remainder == 0
		record_list.each do |key, value|
			tag = remainder - value < 0 ? (remainder + 10 - value) : (remainder - value)
			if record_list.except(key.to_sym).has_value?(tag)
				return remainder
			end
		end
		return 0
  end

  def self.compare 
    time_at = Time.current.strftime("%Y%m%d%H%M%S")  # 记录时间,最后生成的文件加上时间戳
    File.readlines("#{Rails.root}/public/LJ-poker.txt").each do |line| # LJ-poker.txt放在了public下面
      record = line.rstrip!.split(';')
      leon_poker = record.first
      judy_poker = record.last
      poker = PokerGame.new(lemo_poker: leon_poker, judy_poker: judy_poker)
      poker.compare_one(leon_poker, judy_poker, time_at)
    end   
  end
  
  def compare_one(leon_poker, judy_poker, time_at)
      # record_init方法处理记录,返回eg: {"C_10"=>9, "D_8"=>7, "D_10"=>9, "S_8"=>7, "D_3"=>2} 
    leon_init = self.record_init(leon_poker) 
    judy_init = self.record_init(judy_poker)
    leon_score = self.get_score(leon_init) # 获取分数
    judy_score = self.get_score(judy_init)
    if leon_score != judy_score # 分数不相等情况直接比大小
      tag = leon_score > judy_score
    else  
      # 分数相等的情况,先比较highest_rank
      leon_max = self.highest_rank(leon_init)
      judy_max = self.highest_rank(judy_init)
      if leon_max == judy_max  # highest_rank相等的情况,在比较花色
        leon_color_max = self.highest_color(leon_init, leon_max)
        judy_color_max = self.highest_color(judy_init, judy_max)
        tag = leon_color_max > judy_color_max
      else  
        tag =  leon_max > judy_max 
      end
    end
    winner = tag ? 'leon' : 'judy' # 记录获胜者
    # 文件记录在public/poker_record文件夹下面,带有时间戳,可多次记录
    File.open("#{Rails.root}/public/poker_record/#{winner}#{time_at}.txt", 'a+') do |file|
      file.puts "#{leon_poker};#{judy_poker}"
    end
    self.winner = winner
    self.save # 记录结果也报错到数据库中
    return winner
  end

  def highest_rank(records)
    records.keys.map {|k| k.split("_").last.to_i}.max
  end

  def highest_color(records, max_num)
    records.keys.select {|item| item.include?(max_num.to_s)}.map {|k| PokerGame::COLOR[k[0]]}.max
  end
end
