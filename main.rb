require_relative 'string'

class Game
  attr_reader :correct_letters
  def initialize
    @incorrect_guesses = 10
    @guessed_letters = []
    @word = get_random_word.split('')
    @correct_letters = @word.map{'_'}
  end

  def play?
    until @incorrect_guesses == 0
      puts "Letters guessed:  #{@guessed_letters.join(' ')}"
      puts "Incorrect guesses remaining: #{@incorrect_guesses}".yellow
      print_correct_letters
      guess = input_guess
      check_guess(guess)
      if @word == @correct_letters
        puts @word.join('').blue
        return true
      end
    end
    puts "The answer is: #{@word.join('')}".blue
    return false
  end
   
  def input_guess
    print "Enter a letter, or type save to save progress: "
    input = gets.chomp.downcase
    until input == 'save' || (input.length == 1 && input[0].ord >= 97 && input[0].ord<=122)
      print "Please enter a letter (a-z) or save to save the game progress: ".red
      input = gets.chomp.downcase
    end
    input
  end

  def check_guess(guess)
    if @guessed_letters.include?(guess) == true
      puts "\n\n"
      puts "You have already guessed that letter.".red
    elsif @word.include?(guess) == false
      puts "\n\n"
      puts "Wrong guess".red
      @incorrect_guesses-=1
      @guessed_letters << guess
    else
      @guessed_letters << guess
      matched_index = []
      @word.each_with_index do |value, index|
        if value == guess
          matched_index << index
        end
      end 
      matched_index.each {|index| @correct_letters[index] = guess}
      puts "\n\n"
      puts "Good Guess!".green
    end
  end

  def print_correct_letters
    puts @correct_letters.join(' ').blue
  end

  def get_random_word
    file = File.open('5desk.txt','r')
    words = file.readlines.map(&:chomp).select{|word| word.length>=5 && word.length<=12}.map{|word| word.downcase}
    file.close
    prng = Random.new
    random_index = prng.rand(0..words.length-1)
    words[random_index]
  end
end

def main
  game = Game.new
  victory = game.play?
  if victory == true
    puts "You won the game, congratulations."
  else
    puts "You lose, good luck next time."
  end
end

main
