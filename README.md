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
    1. Création du state et du store
    2. Création du middleware et de l'injection de dépendances
    3. Création du reducer
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

Il ne nous reste ensuite plus qu'à l'utiliser dans basic_activity_page.dart, puis à appliquer le même principe à nos autres composants

![Extraction autres](./screenshots/extract_other_components.png)

Pour voir l'implémentation finale, checkout fin_extraction_widgets

### Extraction des différents styles de textes et autres constantes.
Dans une logique de factorisation et d'uniformisation de notre UI, nous conseillons aussi de centraliser dans des fichiers dédiés, les différents types de typo et de couleurs que l'app peut utiliser. 
Il est également conseillé dans la mesure du possible de faire correspondre ces couleurs avec les nommages utilisés par les deisgners.

Dans notre cas nous allons donc créer deux fichiers :
 - codelab_colors.dart
```dart
class CodelabColors {
  static const primary = Color(0xFF673AB7);
  static const primaryLight = Color(0xFFEDE7F6); 
}
```
 - codelabs_text_styles.dart
```dart
class CodelabTextStyles {
  static const text24_bold_black = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const text20_black = TextStyle(fontSize: 20);
  static const text18_bold_black = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const text18_black = TextStyle(fontSize: 18);
  static const text16_black = TextStyle(fontSize: 16);
}
```

Pour voir l'implémentation finale, checkout fin_extraction_constants_ui


## Architecture logicielle
Dans la suite de ce codelab, nous allons détailler différentes manières que nous avons d'architecturer notre code. Le tout pour répondre à 4 problématiques principales : 
 - Lisibilité : pouvoir rapidement comprendre le rôle de chacune de nos classes.
 - Testabilité : pouvoir s'assurer d'avoir un harnais de tests efficace permettant d'ajouter de nouvelles features sans risquer de casser les anciennes.
 - Maintenabilité : pouvoir simplement et rapidement identifier à quel endroit, et de quelle manière apporter une modification / correction. 
 - Réutilisabilité : pouvoir réutiliser une brique logicielle à différents endroits sans avoir à la dupliquer.

Chez OCTO, quelque soit la technologie, différents types d'architectures sont possibles, mais les principes guidants le choix de cette architecture restent les mêmes.

### Extraction de l'appel réseau dans un repository et test du repository.
Lorsque nous procédons à des appels réseaux, nous conseillons de toujours d'isoler la partie réseau dans une classe à part, et nous la nommons la plupart du temps repository.
Dans l'optique de rendre cette classe facile à tester, nous allons lui injecter un client réseau, qui sera mocké dans les tests.
Pour le reste, la classe est reponsable de l'appel réseau, de la déserialization de la réponse et de sa transformation en objet métier.

Dans notre cas on aura :
activity_repository.dart
```dart
import 'dart:convert';

import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ActivityRepository {
  final Client httpClient;

  ActivityRepository(this.httpClient);

  /// Will return null in case of error
  Future<Activity?> getActivity(RangeValues priceRangeValue, RangeValues accessibilityRangeValue, int participants) async {
    try {
      final priceSuffix = '&minprice=${priceRangeValue.start / 100}&maxprice=${priceRangeValue.end / 100}';
      final accessibilitySuffix =
          '&minaccessibility=${accessibilityRangeValue.start / 100}&maxaccessibility=${accessibilityRangeValue.end /
          100}';
      var uri =
          'https://www.boredapi.com/api/activity?participants=${participants
          .toString()}$priceSuffix$accessibilitySuffix';
      final url = Uri.parse(uri);
      final response = await httpClient.get(url);
      final json = jsonDecode(response.body);
      return Activity(
        label: json['activity'] as String,
        type: json['type'] as String,
        participants: (json['participants'] as num).toInt(),
        price: (json['price'] as num).toDouble() * 100,
        accessibility: (json['accessibility'] as num).toDouble() * 100,
      );
    } catch (e) {
      return null;
    }
  }
}
```

Une fois ce repository créé, on peut lui affecter une classe de test.
Par convention, en flutter, les tests sont dans un fichier sous le format nom_implementation_test.dart
Donc pour nous activity_repository_test.dart

La lib réseau utilisée ici (http) nous fournit un `MockClient` permettant de simuler une réponse du réseau : 
```dart
final client = MockClient((request) async {
  path = request.url.toString();
  return Response(
    """
    {
      "activity": "Learn how to iceskate or rollerskate",
      "type": "recreational",
      "participants": 1,
      "price": 0.1,
      "link": "",
      "key": "5947957",
      "accessibility": 0.25
    }
    """,
    200,
    headers: {'content-type': 'application/json'},
  );
});
```

Petite précision, sur dart, les classes n'ont pas de methodes equals permettant de les comparer par défaut.
Ainsi, deux instances d'une même classes seront toujours considérées comme différentes si on n'override pas leur methode equals.
Pour éviter de le faire à la main, nous utilisons habituellement la lib [Equatable](https://pub.dev/packages/equatable)
Et nous pourrons ainsi simplement faire une comparaison à l'aide d'un expect dans notre test.

Ensuite, c'est du classique Given When Then, comme sur chaque projet.

Pour voir l'implémentation finale, checkout fin_extract_repository

### Implémentation suivant l'architecture REDUX.
Parmis les architectures utilisées chez OCTO, on retrouve l'architecture REDUX, venant du Web, et implémentée en suivant la lib [flutter_redux](https://pub.dev/packages/flutter_redux)
![Extraction autres](https://thumbs.gfycat.com/SociableCraftyAlpaca-max-1mb.gif)

Dans notre boucle redux nous retrouverons différents composants :
 - Le store, qui contient tous les autres composants, plus les différents acteurs externes à notre boucle redux (repository, helpers...).
 - Le state, qui contient toutes les donnéees utiles au bon fonctionnement de l'app.
 - Les actions, qui sont dispatchées dans le store et qui servent à communiquer d'une classe à l'autre.
 - Les middlewares, déclenchés par des actions, qui appliquent les règles de gestion et appellent les repository.
 - Les reducers, déclenchés par des actions, qui mettent à jour le state.

Et enfin, nous aurons des ViewModels pour faire le lien entre notre store et nos écrans.

### Création du state et du store. 
Pour commencer, il va nous falloir ajouter la librairie flutter_redux dans notre pubspec.yaml (l. 35)
```yaml
flutter_redux: ^0.10.0
```

Nous allons maintenant devoir créer notre state, et lui donner toutes les informations dont on a besoin pour que notre app fonctionne:
 - un statut indiquant si nous sommes en état Empty (pas de recherche), Erreur, Success ou Loading
 - un résultat dans le cas ou on en a un
 - les filtres à l'instant T

Ce qui chez nous donnera
```dart
class CodelabState extends Equatable {
  final CodelabStatus status;
  final Activity? activity;
  final RangeValues currentPriceFilter;
  final RangeValues currentAccessibilityFilter;
  final int currentParticipantsFilter;

  const CodelabState({
    required this.status,
    required this.activity,
    required this.currentPriceFilter,
    required this.currentAccessibilityFilter,
    required this.currentParticipantsFilter,
  });

  @override
  List<Object?> get props => [
    status,
    activity,
    currentPriceFilter,
    currentAccessibilityFilter,
    currentParticipantsFilter,
  ];
}

enum CodelabStatus {
  EMPTY,
  SUCCESS,
  LOADING,
  ERROR,
}
```
(le state étend Equatable parce que nous aurons par la suite besoin de tester qu'il a les bonnes valeurs dans nos TU)

Une fois notre state créé, nous pouvons créer le store qui lui est associé.
Ce store étant unique et injecté dans l'app à sa création, nous allons le faire dans `main.dart`
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    dynamic reducer;
    final store = Store<CodelabState>(
      reducer,
      initialState: const CodelabState(
        status: CodelabStatus.EMPTY,
        activity: null,
      ),
    );
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const BasicActivityPage(),
      ),
    );
  }
}
```

Notre state initial correspond à ce que nous avions comme données au lancement de `BasicActivityPage`.
Et le widget `StoreProvider` nous permet d'injecter un store utilisable par tous ses enfants. Donc comme il est à la racine de l'app, utilisable par tous nos futurs écrans ou widgets.

### Création du middleware et de l'injection de dépendances.
Maintenant que notre store est injecté dans notre app, nous allons pouvoir le faire dispatcher des actions.
Notre première action sera l'action déclenchée au tap sur le bouton de recherche pour trouver une activité:
codelab_actions.dart
```dart
class FindActivityAction {
  final RangeValues currentPriceFilter;
  final RangeValues currentAccessibilityFilter;
  final int currentParticipantsFilter;

  FindActivityAction({
    required this.currentPriceFilter,
    required this.currentAccessibilityFilter,
    required this.currentParticipantsFilter,
  });
}
```

Dans notre `BasicActivityPage` nous allons maintenant pouvoir récupérer notre store et dispatcher cette action (l.70)
```dart
CodelabButton(
  onTap: () {
      StoreProvider.of<CodelabState>(context).dispatch(FindActivityAction(
        currentParticipantsFilter: _participants.toInt(),
        currentAccessibilityFilter: _accessibilityRangeValue,
        currentPriceFilter: _priceRangeValue,
      ));
  },
  label: 'Search your activity',
)
```

Notre action étant maintenant dispatchée, nous avons besoin d'un middleware pour l'utiliser. 
Avec `flutter_redux`, nous allons utiliser des `MiddlewareClass<CodelabState>` et implémenter nos règles de gestion dans la methode `call`
codelab_middleware.dart
```dart
import 'package:codelab_flutter_at_octo/activity_repository.dart';
import 'package:codelab_flutter_at_octo/codelab_actions.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:redux/redux.dart';

class CodelabMiddleware extends MiddlewareClass<CodelabState> {
  final ActivityRepository repository;

  CodelabMiddleware(this.repository);

  @override
  Future<void> call(Store<CodelabState> store, dynamic action, NextDispatcher next) async {
    next(action);
    if (action is FindActivityAction) {
      final activity = await repository.getActivity(
        action.currentPriceFilter,
        action.currentAccessibilityFilter,
        action.currentParticipantsFilter,
      );
      if (activity == null) {
        store.dispatch(ProcessActivityLoadErrorAction());
      } else {
        store.dispatch(ProcessActivityFoundAction(activity));
      }
    }
  }
}
```

Deux nouvelles actions apparaissent ici : 
 - `ProcessActivityLoadErrorAction` qui indique que nous avons rencontré une erreur
 - `ProcessActivityFoundAction` qui indique que nous avons bien réussi à récupérer notre activité
Ces deux actions seront utilisées plus tard par le reducer pour mettre à jour norte store.

Avant cela, nous devons injecter ce middleware dans notre store.
Et pour ce faire, nous allons injecter également le repository et le client. 
main.dart
```dart
final client = Client();
final repository = ActivityRepository(client);
final store = Store<CodelabState>(
  reducer,
  initialState: const CodelabState(...),
  middleware: [
    CodelabMiddleware(repository),
  ],
);
```
Par la suite, au fur et à mesure que l'application grandit et que nous aurons besoin de nous injecter de plus en plus de classes, il y aura surement besoin d'extraire cette injection dans un autre fichier, voir d'utiliser un framework d'injection, mais le principe restera le même.
Sur certains projet, il est également possible de rencontrer des surcouches aux `MiddlewareClass` comme les `TypedMiddleware`, mais le principe restera aussi le même.

### Création du reducer.
Nos actions étant maintenant prêtes à être processées par notre reducer, nous allons maintenant pouvoir nous attaquer à lui.
Sur `flutter_redux`, le reducer est une methode statique qui prend en entrée le state actuel et une action, et retourne le nouveau state.
codelab_reducer.dart
```dart
CodelabState reducer(CodelabState currentState, dynamic action) {
  if (action is FindActivityAction) {
    return CodelabState(
      status: CodelabStatus.LOADING,
      activity: null,
    );
  }
  if (action is ProcessActivityLoadErrorAction) {
    return CodelabState(
      status: CodelabStatus.ERROR,
      activity: null,
    );
  }
  if (action is ProcessActivityFoundAction) {
    return CodelabState(
      status: CodelabStatus.SUCCESS,
      activity: action.activity,
    );
  }
  return currentState;
}
```

### Création du viewModel et affichage
Notre boucle redux étant maintenant prêt, il est temps de l'utiliser sur notre écran. 
Pour cela nous allons utiliser un Widget venant de `flutter_redux` : `StoreConnector`
basic_activity_page.dart
```dart
return Scaffold(
  body: StoreConnector<CodelabState, CodelabViewModel>(
    converter: (store) => CodelabViewModel.fromStore(store),
    distinct: true,
    builder: (context, vm) {
      return Column(...);
    }
  ),
);
```
le paramètre converter est une methode transformant notre store en un view model.
le paramètre distinct indique que l'on ne veut recharger l'écran que si le viewModel a changé.
le paramètre builder correspond à l'écran que nous voulons retourner en fonction du view model que l'on a.

Avec notre `CodelabViewModel` qui contient les informations d'affichage : 
```dart
import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:equatable/equatable.dart';
import 'package:redux/redux.dart';

class CodelabViewModel extends Equatable {
  final bool loading;
  final bool error;
  final Activity? activity;

  const CodelabViewModel({
    required this.loading,
    required this.error,
    required this.activity,
  });

  factory CodelabViewModel.fromStore(Store<CodelabState> store) {
    return CodelabViewModel(
      loading: store.state.status == CodelabStatus.LOADING,
      error: store.state.status == CodelabStatus.ERROR,
      activity: store.state.activity,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    activity,
  ];
}
```
Il étend `Equatable` pour ne pas recharger l'écran à chaque nouvelle instance mais bien quand il est différent.

Enfin, dans notre vue, nous pouvons utiliser les valeurs du view model pour avoir le bon affichage:
basic_activity_page.dart (l.64)
```dart
Expanded(
  child: _Content(
    loading: vm.loading,
    error: vm.error,
    activity: vm.activity,
  ),
),
```

Pour voir l'implémentation finale, checkout fin_redux