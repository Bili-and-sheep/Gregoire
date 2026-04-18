from itertools import count
import re

from wordfreq import top_n_list
import random

life = 5


words = top_n_list('fr', 100_00)  # 300k most common English words
RandomWord = random.choice(words)

print(RandomWord)





def revealword() :
    coverWord = ("-"*(len(RandomWord)))
    listLetterInWord = list(coverWord)
    if userInput in RandomWord:
        print("Reveal word")
        if coverWord != RandomWord:
            if userInput.find(RandomWord):
                positions = [i for i, c in enumerate(RandomWord) if c == userInput]
                print(positions)
                for position in positions:
                    listLetterInWord[position] = userInput
                coverWord = "".join(listLetterInWord)
                print(coverWord)
        else:
            print("Reveal word")
            print(RandomWord)
            print("GG")

userInput = input("Votre Guess ? (Lettre/Mot) : ").strip().lower()
revealword()


