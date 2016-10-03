
require './config'
require 'curb-fu'
require 'json'

class Hangmanitor

  def self.start_game_process
    total_word_count = 80
    current_word_count = 0

    correct_word_count = 0

    large_word_list = construct_large_word_list

    next_action = "STARTGAME"
    sessionId = start_game

    while(current_word_count < total_word_count)
      next_action = "NEXTWORD"
      word_to_guess = next_word(sessionId)

      used_guesses = Array.new
      wrong_guesses = Array.new
      star_count = word_to_guess.count("*")
      length = word_to_guess.length
      if length < 5
        current_word_count = current_word_count + 1
        next
      end
      best_letters_array = ConfigFile::BEST_LETTERS[length]
      counter = 0

      while star_count!=0 && wrong_guesses.size < length && counter < best_letters_array.size
        guessed_letter = best_letters_array[counter]
        data = guess_word sessionId,guessed_letter
        word_to_guess = data["word"].downcase
        new_star_count = word_to_guess.count("*")
        if new_star_count < star_count
          star_count = new_star_count
        else
          wrong_guesses.push(guessed_letter)
        end
        used_guesses.push(guessed_letter)
        counter = counter + 1
      end

      best_letters_array = get_word_array_from_pattern(large_word_list, wrong_guesses, word_to_guess) - used_guesses
      error_limit = 6

      while best_letters_array.first && wrong_guesses.size < 6
        guessed_letter = best_letters_array.first
        data = guess_word sessionId, guessed_letter
        word_to_guess = data["word"].downcase
        new_star_count = word_to_guess.count("*")
        if new_star_count == star_count
          wrong_guesses.push(guessed_letter)
        end
        star_count = new_star_count
        used_guesses.push(guessed_letter)
        best_letters_array = get_word_array_from_pattern(large_word_list, wrong_guesses, word_to_guess) - used_guesses
      end
      current_word_count = current_word_count + 1
      correct_word_count = correct_word_count + 1 if star_count == 0
      if current_word_count - correct_word_count > 15
        self.start_game_process
      end
    end

    result = get_result(sessionId)
    if result["score"] > 1000
      puts(submit_score(sessionId))
    else
      self.start_game_process
    end
  end

  def self.construct_large_word_list
    words = Array.new
    file = File.open("words.txt","r")
    while(line = file.gets)
      words.push(line.chomp)
    end
    words
  end

  def self.start_game
     data = get_request_data({ "playerId": ConfigFile::PLAYERID, "action": "startGame"})
     total_word_count = data["data"]["numberOfWordsToGuess"]
     data["sessionId"]
  end

  def self.next_word sessionId
    data = get_request_data({ "sessionId": sessionId, "action": "nextWord"})
    current_word_count = data["data"]["totalWordCount"]
    data["data"]["word"]
  end

  def self.guess_word sessionId,guessed_letter
    data = get_request_data ({ "sessionId": sessionId, "action": "guessWord", "guess": guessed_letter.upcase})
    data["data"]
  end

  def self.get_result sessionId
    data = get_request_data ({ "sessionId": sessionId, "action": "getResult" })
    data["data"]
  end

  def self.submit_score sessionId
    data = get_request_data({ "sessionId": sessionId, "action": "submitResult" })
    data["message"]
  end

  def self.get_request_data data
    response = CurbFu.post(ConfigFile::URL,data.to_json)
    JSON.parse(response.body)
  end

  def self.get_word_array_from_pattern large_word_list,wrong_guesses,word_to_guess
    selected = large_word_list.select { |w| Regexp.new("^#{word_to_guess.gsub("*",".")}$") =~ w }
    selected =  selected.select { |w| Regexp.new("^[^#{wrong_guesses.join('')}]*$") =~ w } if wrong_guesses.first
    next_words = Hash.new
    selected.each do | word |
      word.split('').each do | w |
        next_words[w] = (next_words.keys.include?(w)) ? next_words[w] + 1 : 1
      end
    end
    next_words.sort_by { |k,v| v}.map { |k,v| k}.reverse
  end
end

Hangmanitor.start_game_process
