from wordfreq import top_n_list
import random

# Mot aléatoire en français
words = top_n_list('fr', 10_000)
random_word = random.choice(words)

def hangman(life):
    stages = [
        """
         +---+
         |   O
         |  /|\\
         |  / \\
         |
       =======
       GAME OVER
        """,
        """
         +---+
         |   O
         |  /|\\
         |  /
         |
       =======
        """,
        """
         +---+
         |   O
         |  /|\\
         |
         |
       =======
        """,
        """
         +---+
         |   O
         |  /|
         |
         |
       =======
        """,
        """
         +---+
         |   O
         |   |
         |
         |
       =======
        """,
        """
         +---+
         |   O
         |
         |
         |
       =======
        """,
        """
         +---+
         |
         |
         |
         |
       =======
        """,
        """
         |
         |
         |
         |
       =======
        """,
        """






       =======
        """
    ]
    print(stages[life])

def reveal_word():
    life = 8
    print(random_word)
    cover_word = ["-"] * len(random_word)

    print("Mot à deviner :", "".join(cover_word))

    while life > 0 and "-" in cover_word:
        user_input = input("Votre guess (lettre ou mot) : ").strip().lower()

        if user_input == random_word:
            print(f"Bravo ! Le mot était : {random_word}")
            return

        if len(user_input) == 1:
            if user_input in random_word:
                for i, c in enumerate(random_word):
                    if c == user_input:
                        cover_word[i] = user_input
                print("Correct :", "".join(cover_word))
            else:
                life -= 1
                hangman(life)
                print("Incorrect :", "".join(cover_word))
                print(f"Il vous reste : {life} vie")
        else:
            life -= 1
            hangman(life)

    if "-" not in cover_word:
        print(f"🎉 Gagné ! Le mot était : {random_word}")
    else:
        print(f"❌ Perdu ! Le mot était : {random_word}")

reveal_word()
