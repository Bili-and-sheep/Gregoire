from wordfreq import top_n_list
import random

words = top_n_list('fr', 100_00)  # 300k most common English words
RandomWord = random.choice(words)

print(RandomWord)

def hangman(life):
    if life == 8:
        print("""





           =======
           """)
    elif life == 7:
        print("""
             |
             |
             |
             |
             |
           =======
           """)
    elif life == 6:
        print("""
             +---+
             |
             |
             |
             |
           =======
           """)
    elif life == 5:
        print("""
             +---+
             |   O
             |
             |
             |
           =======
           """)
    elif life == 4:
        print("""
             +---+
             |   O
             |   |
             |
             |
           =======
           """)
    elif life == 3:
        print("""
             +---+
             |   O
             |  /|
             |
             |
           =======
           """)
    elif life == 2:
        print("""
             +---+
             |   O
             |  /|\\
             |
             |
           =======
           """)
    elif life == 1:
        print("""
             +---+
             |   O
             |  /|\\
             |  /
             |
           =======
           """)
    elif life == 0:
        print("""
             +---+
             |   O
             |  /|\\
             |  / \\
             |
           =======
           GAME OVER
           """)


def revealword() :
    life = 9
    coverWord = ("-"*(len(RandomWord)))
    listLetterInWord = list(coverWord)
    print("Reveal word")
    while life > 0 or "-" in coverWord:
        userInput = input("Votre Guess ? (Lettre/Mot) : ").strip().lower()

        if userInput == RandomWord :
            print("Guess !")
            break
        else :
            if userInput.find(RandomWord):
                positions = [i for i, c in enumerate(RandomWord) if c == userInput]
                print(positions)
                for position in positions:
                    listLetterInWord[position] = userInput
                coverWord = "".join(listLetterInWord)
                print(coverWord)
            else:
                life = life-1
                print(life)
                hangman(life)



revealword()


