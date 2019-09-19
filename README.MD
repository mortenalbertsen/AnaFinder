This repository finds anagrams of an input phrase among approximately 100000 words. 



## Solution description

Solution is a program written in Swift having a *very basic* UI, which provides no functionality (but I did not want to write a console-application). 

The program finds all three combinations in about 55 seconds, running on 13" 2015 Macbook Pro:

"**printout stout yawls**" hashes to **e4820b45d2277f3844eac66c903e84be**

"**ty outlaws printouts**" hashes to **23170acc097c24edb98fc5488ab033fe**

"**wu lisp not statutory**" hashes to **665e5bcb0c20062fe8abaaf4628bb154**



## Overall flow of program

1. **Initialization**
   1. Read in words-file and filter out irrelevant words
   2. Produce mappings that link "word-sortings" to original words
   3. Produce a mapping [Character -> [Int -> [WordSorting]]]
2. **Core-algorithm**
   1. Run algorithm to find valid word combinations using wordsortings
3. **Test combinations**
   1. Produce all combinations of valid word combinations, now using original words
   2. Test combinations of original words
      1. Write combinations to file
      2. MD5 every line in file and collect result
      3. Search for matches against looked-for MD5s



## Optimizations

The space of possible combinations to test for is enormous, so I prune as much as I can think of. 



### Initial filtering

Initially, I filter out all words that

- contains letters and characters (i.e "`'`'") that are not in reference-anagram.
- contains more occurrences of a single letter than reference-anagram does. For instance the word "anna" is filtered out, since letter "a" only appears once in "poultry outwits ants" but twice in "anna"

This filtering allows me to prune the input-file to approximately 1700 words (from approximately 99000 words)



### Core algorithm

- Identical word-sortings

  - In input file appear words "pils", "slip", "lips" and "spil". These words have the same word-sorting, namely "ilps". Words that share the same word sorting are tested only once in core-algorithm - but will be backtraced to original words if they are part of a valid combination. 
    Testing only unique wordsortings brings down the number of words to test to approximately 1200 (from approximately 1700). 

- Ordering

  - Say I have already tested "cat" + "dog" and it revealed some result XY. Then, there's no need to later on also test for "dog"+"cat", since that combination has the same wordsorting, and thereby reveals the same result XY. 

- Caching / stopwords

  Say that the combination "tapir" (from constituents "ta" and "pir") reveals the result "coco". If we at a later point in time test for the combination "tapir" again but this time from constituents "tap"+"ir", then we're bound to find the same result "coco". I exploit caching to save such results to avoid doing redundant work. 
  Likewise, when a combination A is known to *not* reveal any results, then that combination is saved as a stopword, meaning that if a future combination B equals A, then B won't reveal any results either, but this time I can save myself from doing the hard work of finding out.

- Restricting solutions to a maximum of 4 words only. Using [reverse lookup tables](https://md5.gromweb.com) and the procided reference-hashes I identified what  maximum length I could make algorithm prune for. 

- Work with indices (integers) rather than actual words (strings). Copying indices are low-cost compared to string-copying. 



## Lessons learned

- There are simply too many combinations to make an exhaustive search. 

  For instance:
  "a" - "i" - "l" - "n" - "o" - "o" - "p" - "r" - "s" - "s" - "t" - "t" - "t" - "t" - "u" - "wu" - "y" consist of 17 "words", which amounts to 17! ~ 355 thousand billion anagrams.  

- Swift does not yet  - at least before [macOS Catalina](https://developer.apple.com/documentation/cryptokit/insecure/md5) (due fall 2019) - have a proper MD5 function. 

  - Running a process for each md5-invocation is *way* too costly and slow.
  - Using `awk` for md5'ing is also a lot slower than supplied python script that uses `hashlib`

  

## Future improvements

- Proper unittesting. 
- Test whether performance could be improved by parallel-processing.
- Make program portable; currently certain paths are hardcoded and relies on the existence of `hasher.py` in hardcoded directory. 

