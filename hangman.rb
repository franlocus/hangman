=begin
☻
/▌\
/\
=end
require 'json'


module BasicSerializable

  @@serializer = JSON

  def serialize
    obj = {}
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    @@serializer.dump obj
  end

  def unserialize(string)
    obj = @@serializer.parse(string)
    obj.keys.each do |key|
      instance_variable_set(key, obj[key])
    end
  end
end

module Dictionary
    def self.random
        File.open("5desk.txt") do |file| 
            words = file.readlines.keep_if {|line| (line.length > 6) && (line.length < 13)}
          words.sample.downcase.chomp.chomp.chars
        end
    end
end


class Game
    include BasicSerializable
    include Dictionary
    attr_accessor :lifes, :initial_word, :current_word, :guesses

    
    def initialize
        @lifes = 5
        @initial_word = Dictionary::random
        @current_word = @initial_word.map { "_" }
        @guesses = [[],[]]
    end

    def start_game
        puts " 
         __| |___________| |__ 
        (__| |___________| |__)
           | |  Hangman  | |   
         __| |___________| |__ 
        (__|_|___________|_|__)
        \n          Get ready to play.\n\nYou have 5 tries to reveal the word.\nGood luck!\n\nWhat would you like to play?\n 1) NEW GAME\n 2) LAST SAVED GAME"
        mode = gets.chomp.to_i
        if mode == 2
            load_game
            puts "Your last stats:\n\nYour guesses:\nGood #{@guesses[0]} - Wrong #{@guesses[1]}"
            new_game
        else
            new_game
        end
    end

    def new_game
        game_info = -> do
             puts "Type ´save´ to save the game and play later.\n\nLifes:#{@lifes}\nCurrent game:\n#{@current_word}\n\nYour guesses:\nGood #{@guesses[0]} - Wrong #{@guesses[1]}"  
                    end
        game_info.call

        until (@lifes == 0)
            print "\nLetter:"
            valid_answer = false
            until valid_answer
                guess = gets.chomp.downcase
                if !@guesses.flatten.include?(guess) && guess.match?(/[a-z]/)
                    valid_answer = true 
                    break
                end
                puts "Please type a valid option, only 1 letter not guessed previously."
            end
            if guess == "save"
                save_game
                puts "Game saved!"
                return 
            elsif @initial_word.include?(guess)
                @guesses[0] << guess
                @initial_word.each_with_index { |letter, idx| guess == letter ? @current_word[idx] = letter : "_" }
                game_info.call
            else 
                @guesses[1] << guess
                @lifes -= 1
                puts "Incorrect :("
                game_info.call
            end

            if @current_word == @initial_word
                puts "\n\nC O N G R A T S !\nYou won."
                return
            end

        end

        puts "\nSorry, you have failed.\nSolution: #{@initial_word.join}"

    end

    def save_game
        File.open("last_game.json", "w"){ |file| file.puts self.serialize }
    end

    def load_game
       self.unserialize(File.open("last_game.json", "r"){ |file| file.read})
    end
end

game = Game.new
game.start_game