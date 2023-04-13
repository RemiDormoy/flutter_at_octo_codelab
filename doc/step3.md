# Intro: Architecture logicielle

Dans la suite de ce codelab, nous allons détailler différentes manières que nous avons d'architecturer notre code. Le tout pour répondre à 4 problématiques principales : 

 - Lisibilité : pouvoir rapidement comprendre le rôle de chacune de nos classes.
 - Testabilité : pouvoir s'assurer d'avoir un harnais de tests efficace permettant d'ajouter de nouvelles features sans risquer de casser les anciennes.
 - Maintenabilité : pouvoir simplement et rapidement identifier à quel endroit, et de quelle manière apporter une modification / correction. 
 - Réutilisabilité : pouvoir réutiliser une brique logicielle à différents endroits sans avoir à la dupliquer.

Chez OCTO, quelle que soit la technologie, différents types d'architectures sont possibles, mais les principes guidants le choix de cette architecture restent les mêmes.

# 3. Extraction de l'appel réseau dans un repository et test du repository.
Lorsque nous procédons à des appels réseaux, nous conseillons de toujours d'isoler la partie réseau dans une classe à part, et nous la nommons la plupart du temps repository.
Dans l'optique de rendre cette classe facile à tester, nous allons lui injecter un client réseau, qui sera mocké dans les tests.
Pour le reste, la classe est reponsable de l'appel réseau, de la déserialization de la réponse et de sa transformation en objet métier.

Dans notre cas on aura :
`activity_repository.dart`
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
Par convention, en flutter, les tests sont dans un fichier sous le format `nom_implementation_test.dart`
Donc pour nous `activity_repository_test.dart`

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

Pour voir l'implémentation finale, checkout `fin_extract_repository`

## La suite 👇
- Focus sur REDUX: [Implémentation suivant l'architecture REDUX](doc/redux/redux.md)
- Focus sur XXX: TODO
