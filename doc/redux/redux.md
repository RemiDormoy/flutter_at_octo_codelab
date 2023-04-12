
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
`codelab_actions.dart`
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
`codelab_middleware.dart`
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
`codelab_reducer.dart`
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
`basic_activity_page.dart` (l.64)
```dart
Expanded(
  child: _Content(
    loading: vm.loading,
    error: vm.error,
    activity: vm.activity,
  ),
),
```

## Stratégie de tests
En dehors des tests sur le repository, nous aurons la plupart du temps deux autres types de tests automatisés sur le projet.
 - des tests unitaires sur le View Model pour nous assurer que le bon state nous donne les bonnes données d'affichage.
 - des tests d'intégration sur la boucle redux pour vérifier que le dispatch d'une action entraine le fait d'obtenir le bon state.

### Tests sur le view model
Pour tester notre view model nous allons avoir besoin d'un store, contenant le state que l'on souhaite tester.
codelab_view_model_test.dart
```dart
// Given
const currentState = CodelabState(status: CodelabStatus.LOADING, activity: null);
final store = Store<CodelabState>(
  reducer,
  initialState: currentState,
);
```
Puis on va simplement s'attendre à avoir les bonnes données
```dart
 // When
final viewModel = CodelabViewModel.fromStore(store);

// Then
expect(viewModel.loading, isTrue);
```

### Tests sur la boucle redux
De la même manière que pour le view model, nous allons avoir besoin de recréer un state.
Cette fois ci en revanche il faudra bien lui ajouter le middleware associé à l'action que l'on veut tester, et aussi le repository mocké.
```dart
// Given
    const currentState = CodelabState(status: CodelabStatus.EMPTY, activity: null);
    final store = Store<CodelabState>(
        reducer,
        initialState: currentState,
        middleware: [
          CodelabMiddleware(_ErrorRepository()),
        ]
    );
```
Ensuite il nous faudra dispatcher notre action, puis "attendre" que notre state se retrouve dans le bon état
```dart
// When
    store.dispatch(FindActivityAction(currentPriceFilter: const RangeValues(0, 1), currentAccessibilityFilter: const RangeValues(0.4, 2), currentParticipantsFilter: 4));
    final finalState = await store.onChange.firstWhere((element) => element.status == CodelabStatus.ERROR);
```
Et enfin, il ne reste plus qu'à tester les paramètres que l'on veut dans notre state
```dart
// Then
expect(finalState.status, CodelabStatus.ERROR);
```

Pour voir l'implémentation finale, checkout `fin_redux`