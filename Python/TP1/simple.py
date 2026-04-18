def menu():
    print("\n" + "=" * 50)
    print("Notes OTERIA")
    print("=" * 50)
    print("1) Entrer des notes")
    print("2) Consulter les moyennes des étudiants")
    print("3) Exporter dans un fichier de notes")
    print("4) Quitter")
    print("=" * 50)


def add_grade(students):
    print("\n--- ENTRÉE DES NOTES ---")
    surname = input("Nom de l'étudiant : ").strip()
    name = input("Prénom de l'étudiant : ").strip()

    if not surname or not name:
        print("Erreur : Le nom et le prénom sont obligatoires.")
        return

    student = f"{surname}_{name}"

    if student not in students:
        students[student] = {
            "nom": surname,
            "prenom": name,
            "grades": {
                "maths": [],
                "français": [],
            }
        }

    print(f"\nÉtudiant : {name} {surname}")
    print("Matières disponibles : maths, français")

    course = input("Matière : ").strip().lower()

    if course not in students[student]["grades"]:
        print(f"Matière '{course}' non reconnue.")
        return

    try:
        grade = float(input("Note (0-20) : "))
        if 0 <= grade <= 20:
            students[student]["grades"][course].append(grade)
            print(f"Note ajoutée : {grade}/20 en {course}")
        else:
            print("La note doit être entre 0 et 20.")
    except ValueError:
        print("Veuillez entrer un nombre valide.")


def moy(grades):
    if not grades:
        return 0.0
    return sum(grades) / len(grades)


def print_moy(students):
    print("\n--- MOYENNES DES ÉTUDIANTS ---")

    if not students:
        print("Aucun étudiant enregistré.")
        return

    for key, student in students.items():
        print(f"\n{student["prenom"]} {student["nom"]}")
        print("-" * 40)

        average_courses = []

        for course, grades in student["grades"].items():
            if grades:
                average = moy(grades)
                average_courses.append(average)
                print(
                    f"  {course.capitalize():12} : {average:.2f}/20 ({len(grades)} note(s))")

        if average_courses:
            global_average = sum(average_courses) / len(average_courses)
            print(f"  {"Moyenne générale":12} : {global_average:.2f}/20")
        else:
            print("  Aucune note enregistrée")


def export(students):
    print("\n--- EXPORT DES grades ---")

    if not students:
        print("Aucun étudiant à exporter.")
        return

    filename = input("Nom du fichier (exemple : grades.txt) : ").strip()

    if not filename:
        filename = "grades.txt"

    try:
        with open(filename, "w", encoding="utf-8") as f:
            for key, student in students.items():
                surname = student["nom"]
                name = student["prenom"]

                avg_maths = moy(student["grades"]["maths"])
                avg_french = moy(student["grades"]["français"])

                global_average = []
                for course, grades in student["grades"].items():
                    if grades:
                        global_average.append(moy(grades))

                global_average = (sum(global_average) /
                                  len(global_average)) if global_average else 0.0

                data = f"{surname}-{name}-{avg_maths:.2f}-{avg_french:.2f}-{global_average:.2f}\n"
                f.write(data)

        print(f"Fichier '{filename}' créé avec succès !")
    except Exception as e:
        print(f"Erreur lors de l'export : {e}")


def main():
    students: dict = {}

    while True:
        menu()
        choix = input("\nVotre choix : ").strip()

        if choix == "1":
            add_grade(students)
        elif choix == "2":
            print_moy(students)
        elif choix == "3":
            export(students)
        elif choix == "4":
            break
        else:
            print("Choix invalide. Veuillez choisir entre 1 et 4.")


if __name__ == "__main__":
    main()
