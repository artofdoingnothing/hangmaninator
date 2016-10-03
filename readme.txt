

The program is to be initialised by running the the command
          "ruby the_hangmaninator.rb"
It requires the CurbFu gem to make api requests .

The program algorithm is as follows

1) A request is sent to the Hangman API server to start the game
  1.1) a large list of words is generated from a file consisiting of 355k words
  1.2) This list was used to generate a pre defined hash consisting of the length as key and the values as the top 5 most common appearing letters for that length, Which is kept in a separate
        file . This hash generation is not done each time since the result is the same and its time consuming .
2) The response is parsed and the sessionId is stored for making further requests
3) A counter of 80 words is set and a while loop starts
  3.1) The next word is requested
    3.1.1) If the length is less than 5 characters then the word is skipped as chance to correctly guess the word in 6 turns is not high enough
  3.2) Generation Of a pattern
    3.2.1) The length of the next word is identified
    3.2.2) From a pre generated hash consisting of the length as key and the values as the top 5 most common appearing letters for that length, an array of best possible letters are selected
    3.2.3) These letters are used to guess the word until they run out
    3.2.4) The resulting word which is usually in the form of "**a**b" is converted into a regular expression.
  3.3) The pattern is used to find best possible letters
    3.3.1) The regular expression is used to identify similar words from the large list of 355k words
    3.3.2) These identified words are furthered filtered to remove words containing the wrong guesses
    3.3.3) The words are iterated and the the letters with increasing order of frequency are returned as an array of letters to guess
  3.4) All tried guesses are then removed from this Array
  3.5) The first letter is used to send the guessword API request
    3.5.1) If it succeeds we obtain a new pattern
    3.5.2) If it does not we obtain a wrongly guessed letter which we use to generate the best possible letter again
  3.6) Return to step 3.3 unless error count is more than 6 or the letter has been identified
  3.7) If the difference between correct words and the current number of words is less than 15 then restart the process
  3.8) If the result score at the end of 80 words is less than 1000 (or my last high score) restart the process
  3.9) If its more than 1000 (or my last high score) submit the result

The playerID and the URL can be editted from the config.rb File
The list of 355k words can be found in the words.txt file (open with vim)
