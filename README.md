# codelab_flutter_at_octo

Le but de ce projet est de donner des exemples d'implémentations des concepts de développement que l'on met en place chez OCTO dans le contexte d'une app en flutter.

Il est donc, si ce n'est nécessaire, vivement conseillé de suivre auparavant les codelabs suivant pour monter en compétences sur le framework en lui même: 
 - [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
 - [Basic Flutter layout concepts](https://docs.flutter.dev/codelabs/layout-basics)

 La documentation Flutter prévoit également des pages adressées aux développeurs venant d'autres univers ([Android](https://docs.flutter.dev/get-started/flutter-for/android-devs), [iOS SwiftUI](https://docs.flutter.dev/get-started/flutter-for/swiftui-devs), [iOS UIKit](https://docs.flutter.dev/get-started/flutter-for/uikit-devs), [React Native](https://docs.flutter.dev/get-started/flutter-for/react-native-devs), [web](https://docs.flutter.dev/get-started/flutter-for/web-devs), etc).
 

Il est également conseillé d'utiliser Android Studio étant donné que c'est l'outil principal utilisé par les OCTOs.

## <img width=30 style="vertical-align:bottom" src="https://user-images.githubusercontent.com/73120020/231597453-a7f05c85-5225-4054-9d30-356a0555acd2.png"/> Ask for help ?
 Nous avons un channel Mattermost dédié à Flutter: https://mattermost.octo.tools/software-engineering/channels/flutter

----

## Getting Started

Le point de départ de ce projet est une application qui permet de trouver une activité à faire en fonction de certains critères. 
Cette activité est retournée par un appel API (voir lignes 218 à 226 de `basic_activity_page.dart`).
Partant de ce point de départ, nous allons refactorer ce fichier en suivant différentes guidelines :
 1. [Extraction des différents composants graphiques dans des Widgets.](doc/step1.md)
 2. [Extraction des différents styles de textes et autres constantes.](doc/step2.md)
 3. [Extraction de l'appel réseau dans un repository et test du repository.](doc/step3.md)
 4. [Implémentation suivant l'architecture REDUX](doc/redux/redux.md)
    1. [Création du state et du store](doc/redux/redux.md#création-du-state-et-du-store)
    2. [Création du middleware et de l'injection de dépendances](doc/redux/redux.md#création-du-middleware-et-de-linjection-de-dépendances)
    3. [Création du reducer](doc/redux/redux.md#création-du-reducer)
    4. [Création du viewModel et affichage](doc/redux/redux.md#création-du-viewmodel-et-affichage)
    5. [Stratégie de tests](doc/redux/redux.md#stratégie-de-tests)
    6. [Tests sur le view model](doc/redux/redux.md#tests-sur-le-view-model)
    7. [Tests sur la boucle redux](doc/redux/redux.md#tests-sur-la-boucle-redux)
 5. Implémentation suivant l'architecture XXX
    1. TODO