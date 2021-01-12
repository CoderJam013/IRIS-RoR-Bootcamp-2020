# The function `lower_case` takes an array of strings and converts
# any non-lower case alphabet (A..Z) to corresponding lower case
# alphabet
def lower_case(words)
  output = []
  words.each {|word| output.push(word.downcase)}
  return output
end

# Similar to `lower_case`, this function modifies the array in-place
# and does not return any value.
def lower_case!(words)
  words.map {|word| word.downcase!}
end

# Given a prefix and an array of words, return an array containing
# words that have same prefix.
#
# For example:
# words_with_prefix('apple', ['apple', 'ball', 'applesauce']) would
# return the words 'apple' and 'applesauce'.
def words_with_prefix(prefix, words)
  output = []
  words.each {|word| if word.start_with?(prefix); output.push(word); end}
  return output 
end

# The similarity score between two words is defined as the length of
# largest common prefix between the words.
#
# For example:
# - Similarity of (bike, bite) is 2 as 'bi' is the largest common prefix.
# - Similarity of (apple, bite) is 0 as there are no common letters in
#   the prefix
# - similarity of (applesauce, apple) is 5 as 'apple' is the largest
#   common prefix.
# 
# The function `similarity_score` takes two words and returns the
# similarity score (an integer).
def similarity_score(word_1, word_2)
  counter = 0
  while word_1[counter] == word_2[counter] && counter < word_1.length && counter < word_2.length;  
    counter+=1;   end;
  return counter
end

# Given a chosen word and an array of words, return an array of word(s)
# with the maximum similarity score in the order they appear.
def most_similar_words(chosen_word, words)
  output = []
  max_score = 0
  words.each do |word|
    score = similarity_score(chosen_word, word)
    if score > max_score
      max_score = score
      output = [word]
    elsif score == max_score
      output.push(word)
    end
  end
  return output
end
