def display_pendu(self):
    if errors == 0:
        print("""





        =======
        """)
    elif errors == 1:
        print("""
          |
          |
          |
          |
          |
        =======
        """)
    elif errors == 2:
        print("""
          +---+
          |
          |
          |
          |
        =======
        """)
    elif errors == 3:
        print("""
          +---+
          |   O
          |
          |
          |
        =======
        """)
    elif errors == 4:
        print("""
          +---+
          |   O
          |   |
          |
          |
        =======
        """)
    elif errors == 5:
        print("""
          +---+
          |   O
          |  /|
          |
          |
        =======
        """)
    elif errors == 6:
        print("""
          +---+
          |   O
          |  /|\\
          |
          |
        =======
        """)
    elif errors == 7:
        print("""
          +---+
          |   O
          |  /|\\
          |  /
          |
        =======
        """)
    elif errors == 8:
        print("""
          +---+
          |   O
          |  /|\\
          |  / \\
          |
        =======
        GAME OVER
        """)


# Example usage
errors = 0
while errors <= 8:
    display_pendu(errors)
    errors += 1

