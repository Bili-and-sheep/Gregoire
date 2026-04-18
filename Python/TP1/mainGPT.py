"""""
Grâce à la syntaxe vu précédemment en cours, réaliser un système de notes en Python.

Fonctionnement :
1.Le programme affiche un menu principal permettant à l’utilisateur d’entrer des notes, de consulter les
moyennes et d’exporter les notes dans un fichier
2.Pour entrer les notes, on demandera le nom, le prénom, et la matière
3.Consulter les moyennes affiche toutes les moyennes de tous les étudiants (moyenne générale
comprise)
4.Exporter le fichier demande le nom du fichier puis exporte chaque étudiant au format
a.nom-prenom-moyenne_matiere_1-moyenne_matiere_2...-moyenne_generale

Dès que cela est mis en place, faire une autre version cette fois-ci en version orienté objet.
"""
class Etudiant:
    def __init__(self, nom, prenom):
        self.nom = nom
        self.prenom = prenom
        self.matieres = {}

    def ajouter_note(self, matiere, note):
        if matiere not in self.matieres:
            self.matieres[matiere] = []
        self.matieres[matiere].append(note)

    def moyenne_matiere(self, matiere):
        notes = self.matieres[matiere]
        return sum(notes) / len(notes)

    def moyenne_generale(self):
        moyennes = [self.moyenne_matiere(m) for m in self.matieres]
        return sum(moyennes) / len(moyennes)


class GestionNotes:
    def __init__(self):
        self.etudiants = {}

    def obtenir_etudiant(self, nom, prenom):
        cle = (nom, prenom)
        if cle not in self.etudiants:
            self.etudiants[cle] = Etudiant(nom, prenom)
        return self.etudiants[cle]

    def entrer_notes(self):
        nom = input("Nom : ")
        prenom = input("Prénom : ")
        matiere = input("Matière : ")
        note = float(input("Note : "))

        etudiant = self.obtenir_etudiant(nom, prenom)
        etudiant.ajouter_note(matiere, note)

    def consulter_moyennes(self):
        for etudiant in self.etudiants.values():
            print(f"\n{etudiant.nom} {etudiant.prenom}")
            for matiere in etudiant.matieres:
                print(f"  {matiere} : {etudiant.moyenne_matiere(matiere):.2f}")
            print(f"  Moyenne générale : {etudiant.moyenne_generale():.2f}")

    def exporter(self):
        nom_fichier = input("Nom du fichier : ")

        with open(nom_fichier, "w", encoding="utf-8") as fichier:
            for etudiant in self.etudiants.values():
                ligne = f"{etudiant.nom}-{etudiant.prenom}"
                for matiere in etudiant.matieres:
                    ligne += f"-{etudiant.moyenne_matiere(matiere):.2f}"
                ligne += f"-{etudiant.moyenne_generale():.2f}\n"
                fichier.write(ligne)


def menu():
    gestion = GestionNotes()

    while True:
        print("\n--- MENU ---")
        print("1. Entrer des notes")
        print("2. Consulter les moyennes")
        print("3. Exporter")
        print("4. Quitter")

        choix = input("Choix : ")

        if choix == "1":
            gestion.entrer_notes()
        elif choix == "2":
            gestion.consulter_moyennes()
        elif choix == "3":
            gestion.exporter()
        elif choix == "4":
            break
        else:
            print("Choix invalide.")


menu()
