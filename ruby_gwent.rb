$all_cards = []
$opponentHand = []
$opponentDeck = []
$player_hand = []
$playerDeck = []
$round_number = 0

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(91)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end

$game_board = {
  close_combat:
  { name: "Close Combat Row",
    weather: false,
    multiplier: false,
    row: []
  },

  ranged_combat:
  { name: "Ranged Combat Row",
    weather: false,
    multiplier: false,
    row: []
  },

siege_combat:
  { name: "Siege Combat Row",
    weather: false,
    multiplier: false,
    row: []
  }
}

  # Have to rewrite as object
  class Game
    attr_reader :agame_board, :round_scores

    def initialize(agame_board)
      @agame_board = agame_board

      @round_scores =
         {
          player1: 0,
          player2: 0
        }

    end

    def deal_cards(player, full_deck)
      temp_deck = full_deck
      temp_deck.shuffle!

      10.times do |x|
        player.deck.push(temp_deck.slice!(0))
      end
    end

  end

  class Player
    attr_reader :game_board, :name, :deck, :discard, :close, :ranged, :siege

    def initialize(game_board, name, deck)
      @game_board = game_board
      @name = name
      @deck = deck
      @discard = []
      @close = @game_board[:close_combat][:row]
      @ranged = @game_board[:ranged_combat][:row]
      @siege = @game_board[:siege_combat][:row]
    end

    def deck
      @deck
    end

    def total_score
      close = @game_board[:close_combat][:row]
      ranged = @game_board[:ranged_combat][:row]
      siege = @game_board[:siege_combat][:row]
      close_weather = @game_board[:close_combat][:weather]
      ranged_weather = @game_board[:ranged_combat][:weather]
      siege_weather = @game_board[:siege_combat][:weather]
      close_multi = @game_board[:close_combat][:multiplier]
      ranged_multi = @game_board[:ranged_combat][:multiplier]
      siege_multi = @game_board[:siege_combat][:multiplier]

        score = get_score(close, close_weather, close_multi) +
        get_score(ranged, ranged_weather, ranged_multi) +
        get_score(siege, siege_weather, siege_multi)

    end

    def get_score (arr, status, multiplier)
         score = 0
         if status == true
           score =  arr.length
         else
         arr.each do |card|
           score += card.strength
         end
         if multiplier == true
           return score * 2
         else
           return score
       end
       end
     end

    def show_cards
      i = 1
      for el in self.deck
        if el.strength != 0
          print "|\##{i} #{el.name}: #{el.type.capitalize} #{el.strength}".colorize(33)
        else
          print "|\##{i} #{el.name}: #{el.type.capitalize} ".colorize(33)

        end
        i += 1
      end
    end

    def select_card(card)
        card = card.to_i
        card -= 1
        selected_card = deck[card]
        puts selected_card.name + " played by #{self.name}"
        place_card(selected_card, card)
    end

      def place_card(card, card_index)
        if card.name == "Mud" || card.name == "Fog" || card.name == "Rain"
          add_weather($player, $opponent, deck[card_index])
          deck.slice!(card_index)

         elsif card.name == "Clear"
           clear_weather($player)
           clear_weather($opponent)
           deck.slice!(card_index)

         elsif card.name.include?("Spy")
           if self.name == "Player"
             $opponent.game_board[card.row][:row].push(deck.slice!(card_index))
           else
             $player.game_board[card.row][:row].push(deck.slice!(card_index))
           end
            puts "spying"
            deck.push($all_cards.shuffle[0])
            deck.push($all_cards.shuffle[0])
          #deck.push(discard.slice!(0))

         elsif card.name == "Horn"
           if self.name == "Player"
             print "Select a row to use the horn on, s for siege, r for ranged, or c for close. "
             horn = gets.chomp.downcase
           while !horn.match(/[crs]/)
             print "Select a row to use the horn on, s for siege, r for ranged, or c for close. "
             horn = gets.chomp.downcase
          end
          else horn = ["r","s","c"].shuffle[0]
         end
           if horn == 'c'
             @game_board[:close_combat][:multiplier] = true
           elsif horn == 'r'
             @game_board[:ranged_combat][:multiplier] = true
           else
             @game_board[:siege_combat][:multiplier] = true
           end
           deck.slice!(card_index)

        else
        game_board[card.row][:row].push(deck.slice!(card_index))
      end
      end

      def clear_weather(player)
          player.game_board[:close_combat][:weather] = false
          player.game_board[:ranged_combat][:weather] = false
          player.game_board[:siege_combat][:weather] = false
      end

      def clear_horn(player)
          player.game_board[:close_combat][:multiplier] = false
          player.game_board[:ranged_combat][:multiplier] = false
          player.game_board[:siege_combat][:multiplier] = false
      end

      def add_weather(player, opponent, card)
        player.game_board[card.row][:weather] = true
        opponent.game_board[card.row][:weather] = true
      end

    end

  class Card
    attr_reader :type, :name, :strength, :row, :col

    def initialize(type, name, strength, row, col)
      @type = type
      @name = name
      @strength = strength
      @row = row
      @col = col
      $all_cards.push(self)
    end


  end
  # $board = $board.new("player1", "player2")
  $board = Game.new($game_board)
  $player = Player.new( {
    close_combat:
    { name: "Close Combat Row",
      weather: false,
      effect: "Mud ^ ",
      multiplier: false,
      row: []
    },

    ranged_combat:
    { name: "Ranged Combat Row",
      weather: false,
      effect: "Fog > ",
      multiplier: false,
      row: []
    },

  siege_combat:
    { name: "Siege Combat Row",
      weather: false,
      effect: "Rain ~",
      multiplier: false,
      row: []
    }
  }, "Player", [])

  $opponent = Player.new({
    close_combat:
    { name: "Close Combat Row",
      weather: false,
      effect: "Mud ^ ",
      multiplier: false,
      row: []
    },

    ranged_combat:
    { name: "Ranged Combat Row",
      weather: false,
      effect: "Fog > ",
      multiplier: false,
      row: []
    },

  siege_combat:
    { name: "Siege Combat Row",
      weather: false,
      effect: "Rain ~",
      multiplier: false,
      row: []
    }
  }, "Opponent", [])
  #$player2 = $board.new(player2(Board.deal_cards($allCards)))

  #Generate Deck
  # peasant = Card.new("s", "Peasant", 1, :close_combat, 1),
  # merchant = Card.new("s", "Merchant", 1, :close_combat, 2),
  # dog = Card.new("s", "Dog", 5, :siege_combat, 0),
  # horse = Card.new("s", "Horse", 1, :siege_combat, 0),
  # village = Card.new("s", "Village", 5, :siege_combat, 0),
  # town = Card.new("s", "Town", 5, :siege_combat, 0),
  # castle = Card.new("s", "Castle", 5, :close_combat, 2),
  # infantry = Card.new("s", "Infantry", 2, :close_combat, 2),
  # soldier = Card.new("s", "Soldier", 3, :close_combat, 2),
  # mage = Card.new("s", "Mage", 5, :siege_combat, 0),
  wizard = Card.new("s", "Magical Wizard", 5, :siege_combat, 0),
  witch = Card.new("s", "Witch", 5, :siege_combat, 0)
  knight = Card.new("c", "Knight", 6, :close_combat, 2)
  bishop = Card.new("s", "Bishop", 7, :siege_combat, 0)
  queen = Card.new("c", "Queen", 8, :close_combat, 2)
  spy = Card.new("c", "Close Spy", 3, :close_combat, 2)
  spy = Card.new("r", "Ranged Spy", 5, :ranged_combat, 2)
  spy = Card.new("s", "Siege Spy", 8, :siege_combat, 2)
  king = Card.new("r", "King", 10, :ranged_combat, 1)
  hero = Card.new("s", "Hero", 10, :siege_combat, 0)
  thief = Card.new("s", "Thief", 10, :siege_combat, 0)
  trebuchet = Card.new("r", "Trebuchet", 8, :ranged_combat, 1)
  catapault = Card.new("s", "Catapault", 8, :siege_combat, 0)
  curse = Card.new("s", "Curse", 5, :siege_combat, 0)
  death = Card.new("s", "Death", 5, :siege_combat, 0)
  horn = Card.new("w", "Horn", 2, :weather, 0)
  mud = Card.new("weather", "Mud", 0, :close_combat, 0)
  rain = Card.new("weather", "Rain", 0, :siege_combat, 0)
  fog = Card.new("weather", "Fog", 0, :ranged_combat, 0)
  clear = Card.new("weather", "Clear", 0, :weather, 0)
  horn = Card.new("special", "Horn", 2, :weather, 0)

  $board.deal_cards($player, $all_cards)
  $board.deal_cards($opponent, $all_cards)


   $board_gui_lines =
  [
    $opponent.game_board[:siege_combat],
    $opponent.game_board[:ranged_combat],
    $opponent.game_board[:close_combat],
    $player.game_board[:close_combat],
    $player.game_board[:ranged_combat],
    $player.game_board[:siege_combat]
  ]

  def display_board()
    #calculate_scores
    player_score = $player.total_score
    opponent_score = $opponent.total_score
    total_score = 0
    print "\n"
    puts "." *  120 +  "\n"
    print "Round: #{$round_number + 1} \n"
    puts "=" *  120 +  "\n"
    puts "-Opponent-"
    print "Round wins = #{$board.round_scores[:player2]}"
    print "Cards Total = #{opponent_score}".rjust(103) + "\n"
    # puts "Round wins = #{$board.round_scores[:player2]}".rjust(117)
    puts "=" *  120 +  "\n"

    # (0..2).each do |i|
    #   puts $player.game_board.keys[i]
    #      puts $player.game_board[$player.game_board.keys[i]][:weather]
    #    end
    #
      x = 0
      $board_gui_lines.each do |line|
        #print "-" * 120 + "\n"



      if line[:weather] && line[:multiplier]
        #print line
        print "~" * 120 + "< Horn \n"
        print "#{line[:effect]} |"

      elsif line[:multiplier]
        color = 95 #104 bg maybe.. Kind of burns the retinas though
        print "-" * 120 + "< Horn \n"
        print "       |"

      elsif line[:weather]
        color = 95 #104 bg maybe.. Kind of burns the retinas though
        print "~" * 120 + "\n"
        print "#{line[:effect]} |"

      elsif line[:row].empty? == true
        color = 95 #104 bg maybe.. Kind of burns the retinas though
        print "-" * 120 + "\n"
        print "       | #{line[:name]}"
      else

        print "-" * 120 + "\n"
        print "       |"
     end
     x += 1

        line[:row].each do |card|
          color = 33
          multiplier = 1

          if line[:multiplier] == true
            color = 95 #104 bg maybe.. Kind of burns the retinas though
            multiplier *= 2
          end

          if $player.game_board.keys[0] == card.row && line[:weather] == true
             $opponent.game_board[:close_combat][:weather] = true
             print " #{card.name} - #{1 * multiplier} |".red

          elsif $player.game_board.keys[1] == card.row && line[:weather] == true
            $opponent.game_board[:ranged_combat][:weather] = true
            print " #{card.name} - #{1 * multiplier} |".red

          elsif $player.game_board.keys[2] == card.row && line[:weather] == true
            $opponent.game_board[:siege_combat][:weather] = true
            print " #{card.name} - #{1 * multiplier} |".red

            else
            print " #{card.name} - #{card.strength * multiplier} |".colorize(color)
          end

     end
     print " \n"
   end
   puts "=" *  120 + "\n"
   print "Round wins = #{$board.round_scores[:player1]}"
   print  "Cards Total = #{$player.total_score}".rjust(103)
   puts "\n-Player-"
   puts "=" *  120 +  "\n"
   puts "\n"
   print "-" * 120 + "\n"
   $player.show_cards
   print "|"
   puts "\n"
   print "-" * 120
   puts "\n"
   end



 def start_game
   display_board
     while $player.deck.length > 0
     print "\nEnter number of card to play or 'pass' to end the round: "
     card = gets.chomp
    #  puts "\n" * 10
       if card == "quit" || card == "q"
         break
       elsif card == "pass"
        end_round
       elsif card.match(/[1-9]|10/)
         $player.select_card(card)
         $opponent.select_card(card)
         display_board
       else
         print #{}"Type 'commands' to list the available commands, or 'rules' for instructions.\n"
       end
    end
 end

 def clear_board
    $board_gui_lines.each do |line|
      #$player.discard.push(line[:row])
     line[:row] = []

      $player.clear_weather($player)
      $opponent.clear_weather($opponent)
      $player.clear_horn($player)
      $opponent.clear_horn($opponent)
   end
  end


 def end_round
   player_rounds_won = $board.round_scores[:player1]
   opponent_rounds_won = $board.round_scores[:player2]
   player_score = $player.total_score
   opponent_score = $opponent.total_score
    if player_score >= opponent_score
       $board.round_scores[:player1] += 1
       puts "\n" * 10
       puts "*******************Player Wins the round!********************".green
       puts "\n" * 10
       sleep(2)
     else
       puts "\n" * 10
       puts "*****************Opponent Wins the round!*******************".red
       puts "\n" * 10
       sleep(2)
       $board.round_scores[:player2] += 1
    end
    $round_number += 1
    clear_board
    start_game
 end
 start_game


    #puts $game_board[:enemy_ranged][:line]
