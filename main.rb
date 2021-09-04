require_relative 'string'
require 'yaml'

class Game
  def initialize
    @incorrect_guesses = 10
    @guessed_letters = []
    @word = get_random_word.split('')
    @correct_letters = @word.map { '_' }
  end

  def play
    until @incorrect_guesses == 0
      puts "Letters guessed:  #{@guessed_letters.join(' ')}"
      puts "Incorrect guesses remaining: #{@incorrect_guesses}".yellow
      print_correct_letters
      guess = input_guess
      return 'save' if guess == 'save'

      check_guess(guess)
      if @word == @correct_letters
        puts @word.join('').blue
        return 'win'
      end
    end
    puts "The answer is: #{@word.join('')}".blue
    'lose'
  end

  def input_guess
    print 'Enter a letter, or type save to save progress: '
    input = gets.chomp.downcase
    until input == 'save' || (input.length == 1 && input[0].ord >= 97 && input[0].ord <= 122)
      print 'Please enter a letter (a-z) or save to save the game progress: '.red
      input = gets.chomp.downcase
    end
    input
  end

  def check_guess(guess)
    if @guessed_letters.include?(guess) == true
      puts "\n\n"
      puts 'You have already guessed that letter.'.red
    elsif @word.include?(guess) == false
      puts "\n\n"
      puts 'Wrong guess'.red
      @incorrect_guesses -= 1
      @guessed_letters << guess
    else
      @guessed_letters << guess
      matched_index = []
      @word.each_with_index do |value, index|
        matched_index << index if value == guess
      end
      matched_index.each { |index| @correct_letters[index] = guess }
      puts "\n\n"
      puts 'Good Guess!'.green
    end
  end

  def print_correct_letters
    puts @correct_letters.join(' ').blue
  end

  def get_random_word
    file = File.open('5desk.txt', 'r')
    words = file.readlines.map(&:chomp).select do |word|
              word.length >= 5 && word.length <= 12
            end.map { |word| word.downcase }
    file.close
    prng = Random.new
    random_index = prng.rand(0..words.length - 1)
    words[random_index]
  end
end

def main
  puts 'Welcome to Hangman, Would you like to: '
  puts '1. Start a new Game.'
  puts '2. Load a Game.'
  input = gets.chomp.to_i
  until [1, 2].include?(input)
    puts 'Please input between 1 for New Game or 2 for Load Game'.red
    input = gets.chomp.to_i
  end
  if input == 1
    game = Game.new
    result = game.play
  else
    puts 'Here are the current saved games.'
    files = Dir.glob('saves/*').map { |file_path| file_path[6..-1] }
    files.each_with_index { |value, index| puts "#{index + 1}. #{value}" }
    print "Please choose the one you want to load (1-#{files.size}): "
    choice = gets.chomp.to_i
    until choice >= 1 && choice <= files.size
      print "File doesn't exist. Please choose an existing file: ".red
      choice = gets.chomp.to_i
    end
    serialized_game_data = File.read("saves/#{files[choice - 1]}")
    game = YAML.load(serialized_game_data)
    puts "\n\n"
    puts "#{files[choice - 1]} loaded"
    result = game.play
  end

  if result == 'win'
    puts 'You won the game, congratulations.'
  elsif result == 'lose'
    puts 'You lose, good luck next time.'
  else
    print 'Enter a name for your game file: '
    file_name = gets.chomp
    until file_name.empty? == false
      puts 'Please enter the name of your game file, it cannot be empty!'.red
      file_name = gets.chomp
    end
    serialized_game = game.to_yaml
    File.write("saves/#{file_name}", serialized_game)
  end
end

main
