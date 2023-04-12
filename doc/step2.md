# 2. Extraction des différents styles de textes et autres constantes.
Dans une logique de factorisation et d'uniformisation de notre UI, nous conseillons aussi de centraliser dans des fichiers dédiés, les différents types de typo et de couleurs que l'app peut utiliser. 
Il est également conseillé dans la mesure du possible de faire correspondre ces couleurs avec les nommages utilisés par les deisgners.

Dans notre cas nous allons donc créer deux fichiers :
 - `codelab_colors.dart`
```dart
class CodelabColors {
  static const primary = Color(0xFF673AB7);
  static const primaryLight = Color(0xFFEDE7F6); 
}
```
 - `codelabs_text_styles.dart`
```dart
class CodelabTextStyles {
  static const text24_bold_black = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const text20_black = TextStyle(fontSize: 20);
  static const text18_bold_black = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const text18_black = TextStyle(fontSize: 18);
  static const text16_black = TextStyle(fontSize: 16);
}
```

Pour voir l'implémentation finale, checkout `fin_extraction_constants_ui`

## La suite 👉 Partie 3: [Extraction de l'appel réseau dans un repository et test du repository.](doc/step3.md)