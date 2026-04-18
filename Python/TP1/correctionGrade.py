from typing import Self


class Course:
    def __init__(self, name:str):
        self.name = name
        self.marks = list[float] = []
    def add_grade(self, grade:float):
        self.marks.append(grade)




class Student:
    def __init__(self, name:str, sureName:str):
        self.Name = name
        self.SureName = sureName
        self.course ={
            "math" : course("math"),
            "fraçais" : course("français")
        }

    def add_grade(self,course:str, grade:float):
        self.course[course].add_grade(grade)



    def printAVG(self):
        global_average = 0
        print(f"{self.Name} : {self.SureName}")
        print("=" * 50)
        for course in self.course.values() :
            average = course.average
            print(f"{course}")
            global_average += average

        global_average = global_average / len(self.course.values())
        print(f"Moyenne Général : {global_average}")
    def export_line(self) -> str:
        average_math = self.course["math"].average()
        average_french = self.course["français"].average()
        average_general =

        return f"{self.Name} : {self.SureName} : {self.course.}"

    def global_average(self):
        






class Manager:
    def __init__(self):
        self.student = {}

    def menu(self):
        print("=" * 50)
        print("1. Consulter les moyennes")
        print("2. Moyenne Genéral")
        print("3. Exporter les moyennes")
        print("4. Quitter")
        print("=" * 50)

    def AddGrade(self):
        print("------Entrer Note-------")
        name = input("Nom de l'Etudiant : ").strip().lower()
        sureName = input("Prenom de l'Etudiant : ").strip().lower()

        if name or not sureName :
            print("Pas dans la liste")
            return

        student_key = f"{name}_{sureName}"
        if student_key not in self.student :
            self.student[student_key] = Student()# TODO crée étudiant

        student = self.student[student_key]

        print(f"Étudiant : {name} {sureName}")
        print(f"Matière Dispo : Math, Français")
        course = input("Matière Choisi : ").strip().lower()
        if course not in student.course :
            print(f"Matière{course} n'est pas disponible")
            return

        try:
            grade = float(input("Insert Note between 0 & 20").strip())
            student.add_grade(course, grade)
            print("Note Ajoutée")
            return
        except ValueError:
            print("Please insert a valid Note")
            return


    def printAVG(self):
        print("------Moyenne Des Students-------")

        if not self.student :
            print("no students")
            return

        for student in self.student.values() :
            student.printAVG()

    def export_note(self):
        print("------Export Note-------")

        if not self.student :
            print("no students")
            return

        file_name = input("Nom du fichier (grade.txt): ").strip()
        if not file_name :
            file_name = "grade.txt"

        try :
            with open(file_name, "w") as f:
                f.write("# nom-prenom-moy_math-moy_français-moy_general\n")
                for student in self.student.values() :
                    f.write(f"{student.export_line}\n")
            print("Foichier crée")

        except Exception as e:
            print(f"Erreur {e}")











    def run(self):
        self.menu()
        while True:
            # TODO Afficher Menu
            choix = input("Enter your choice: ").strip()
            if choix == "1":
                self.AddGrade()
                # TODO Inséré Note
            if choix == "2":
                self.printAVG()
                # TODO Afficher Moyenne Genéral
            if choix == "3":
                pass
                # TODO Export Note
            if choix == "4":
                break




def main():
    system = Manager()
    system.run()

if __name__ == '__main__':
    main()