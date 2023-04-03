# codelab_flutter_at_octo

Le but de ce projet est de donner des exemples d'implémentations des concepts de développement que l'on met en place chez OCTO dans le contexte d'une app en flutter.

Il est donc, si ce n'est nécessaire, vivement conseillé de suivre auparavant les codelabs suivant pour monter en compétences sur le framework en lui même: 
 - [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
 - [Basic Flutter layout concepts](https://docs.flutter.dev/codelabs/layout-basics)

Il est également conseillé d'utiliser Android Studio étant donné que c'est l'outil principal utilisé par les OCTOs.

## Getting Started

Le point de départ de ce projet est une application qui permet de trouver une activité à faire en fonction de certains critères. 
Cette activité est retournée par un appel API (voir lignes 218 à 226 de basic_activity_page.dart).
Partant de ce point de départ, nous allons refactorer ce fichier en suivant différentes guidelines :
 1. Extraction des différents composants graphiques dans des Widgets.
 2. Extraction de l'appel réseau dans un repository et test du repository.
 3. Implémentation suivant l'architecture REDUX
    1. Injection de dépendances et création du state
    2. Création du middleware et de l'action de get
    3. Création du reducer et de l'action de process
    4. Création du viewModel et affichage
 4. Implémentation suivant l'architecture XXX
    1. TODO


### Extraction des différents composants graphiques dans des Widgets.
Branche de départ : master

bla bla bla bla bla bla
