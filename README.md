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
 2. Extraction des différents styles de textes et autres constantes.
 3. Extraction de l'appel réseau dans un repository et test du repository.
 4. Implémentation suivant l'architecture REDUX
    1. Injection de dépendances et création du state
    2. Création du middleware et de l'action de get
    3. Création du reducer et de l'action de process
    4. Création du viewModel et affichage
 5. Implémentation suivant l'architecture XXX
    1. TODO


### Extraction des différents composants graphiques dans des Widgets.
Branche de départ : master

Pourquoi ce refacto ?
Par soucis de lisibilité et de maintenabilité, il est recommandé de ne pas laisser nos classes atteindre des tailles trop importantes.  
Nous conseillons donc de procéder à un découpage le plus fin possible allant de notre page (`BasicActivityPage` dans notre example) à des widget atomiques (comme un bouton).
En découpant de cette manière, nous pourrons également réutiliser très simplement ces composants dans la même page et/ou sur d'autres écrans.

Comment ?
Tout d'abord, nous allons identifier sur l'écran quel composant extraire, dans notre cas ce sera le bouton du bas
![Extraction bouton](./screenshots/extract_button.png)

L'idée est de créer un `StatelessWidget` ayant dans sa methode build la chaine de Widgets correspondant à notre bouton.
Dans notre cas les lignes 206 à 252.
Ensuite, nous allons définir quels champs sont sensés être parametrables dans ce widget. En suivant si possible l'exemple (et le nommage) des composants du framework. 
Ici, nous aurons donc un paramètre `onTap` comme dans le composant `Inkwell`, et un paramètre `label`: 

codelab_button.dart
```dart
import 'package:flutter/material.dart';

class CodelabButton extends StatelessWidget {
  final void Function() onTap;
  final String label;

  const CodelabButton({
    super.key,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: Material(
        color: Colors.deepPurple,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```




