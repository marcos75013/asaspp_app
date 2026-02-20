import '../domain/quiz_model.dart';

class QuizMockData {
  static List<QuizQuestion> getQuestions(int level) {
    switch (level) {
      case 1:
        return _level1;
      case 2:
        return _level2;
      case 3:
        return _level3;
      default:
        return _level1;
    }
  }

  /// ================================
  /// 🔹 NIVEAU 1 – Débutant
  /// ================================
  static final List<QuizQuestion> _level1 = [
    QuizQuestion(
      question: "Quel équipement permet de respirer sous l’eau ?",
      answers: ["Masque", "Détendeur", "Palmes", "Boussole"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Quelle est la profondeur max conseillée en N1 ?",
      answers: ["20m", "10m", "30m", "40m"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Que signifie le signe OK sous l’eau ?",
      answers: ["Problème", "Je remonte", "Tout va bien", "Danger"],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: "Quel gaz respire-t-on en plongée loisir ?",
      answers: ["Oxygène pur", "Air", "CO2", "Nitrox 100%"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Pourquoi fait-on un palier de sécurité ?",
      answers: ["Repos", "Décompression", "Photo", "Pause fun"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Quel accessoire améliore la vision sous l’eau ?",
      answers: ["Masque", "Palmes", "Ceinture", "Gilet"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Quel élément permet la flottabilité ?",
      answers: ["Gilet stabilisateur", "Palmes", "Ordinateur", "Tuba"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Que doit-on vérifier avant une plongée ?",
      answers: ["Son téléphone", "Son matériel", "La météo TV", "La marée TV"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Combien de bars environ dans une bouteille pleine ?",
      answers: ["50 bars", "100 bars", "200 bars", "500 bars"],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: "La plongée se fait toujours :",
      answers: ["Seul", "En binôme", "En courant", "De nuit uniquement"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "À 10m, la pression est environ de :",
      answers: ["1 bar", "2 bars", "3 bars", "4 bars"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Quel est le rôle des palmes ?",
      answers: ["Respirer", "Se propulser", "Mesurer", "Communiquer"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "On doit remonter :",
      answers: ["Très vite", "Lentement", "En courant", "En apnée"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Que faire si on a froid ?",
      answers: ["Continuer", "Sortir de l’eau", "Plonger plus profond", "Retirer combinaison"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "La combinaison sert à :",
      answers: ["Flotter", "Respirer", "Se protéger du froid", "Décorer"],
      correctIndex: 2,
    ),
  ];

  /// ================================
  /// 🔹 NIVEAU 2 – Intermédiaire
  /// ================================
  static final List<QuizQuestion> _level2 = [
    QuizQuestion(
      question: "Quel est le principal risque en profondeur ?",
      answers: ["Fatigue", "Narcose", "Soif", "Crampes"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "La narcose est causée par :",
      answers: ["Oxygène", "Azote", "CO2", "Froid"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Vitesse de remontée recommandée ?",
      answers: ["30m/min", "20m/min", "10m/min", "5m/min"],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: "Un ordinateur de plongée sert à :",
      answers: ["Calculer la décompression", "Envoyer SMS", "Filmer", "Éclairer"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "En cas de panne d’air ?",
      answers: ["Remonter vite", "Partager l’air", "Attendre", "Enlever masque"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "La flottabilité doit être :",
      answers: ["Positive", "Négative", "Neutre", "Instable"],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: "Un palier obligatoire est :",
      answers: ["Optionnel", "Imposé par tables/ordinateur", "Fun", "Rare"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "La pression augmente de :",
      answers: ["1 bar tous les 10m", "2 bars", "5 bars", "0.5 bar"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Un accident de décompression est dû à :",
      answers: ["Remontée rapide", "Froid", "Fatigue", "Manque d’eau"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Le Nitrox contient plus de :",
      answers: ["Azote", "Oxygène", "CO2", "Hélium"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Un détendeur sert à :",
      answers: ["Baisser pression air", "Augmenter pression", "Filtrer eau", "Gonfler gilet"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "La réserve d’air est souvent à :",
      answers: ["20 bars", "50 bars", "100 bars", "150 bars"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Une plongée profonde augmente :",
      answers: ["Consommation air", "Lumière", "Température", "Vision"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Le lest sert à :",
      answers: ["Respirer", "Descendre", "Voir", "Communiquer"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "On doit planifier la plongée :",
      answers: ["Avant", "Pendant", "Après", "Jamais"],
      correctIndex: 0,
    ),
  ];

  /// ================================
  /// 🔹 NIVEAU 3 – Avancé
  /// ================================
  static final List<QuizQuestion> _level3 = [
    QuizQuestion(
      question: "Un mélange Trimix contient :",
      answers: ["O2 + N2", "O2 + He + N2", "O2 + CO2", "He + CO2"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "L’hyperoxie est due à :",
      answers: ["Excès d’azote", "Excès d’oxygène", "Manque d’air", "Froid"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "La PpO2 max recommandée en plongée loisir ?",
      answers: ["1.4 bar", "2 bars", "0.8 bar", "3 bars"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Un recycleur permet de :",
      answers: ["Recycler l’air expiré", "Filtrer eau", "Chauffer eau", "Créer bulles"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "La profondeur max N3 loisir est souvent :",
      answers: ["40m", "60m", "30m", "20m"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "Un gaz fond est :",
      answers: ["Gaz principal plongée", "Gaz secours surface", "Air froid", "Nitrox pur"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Un parachute de palier sert à :",
      answers: ["Signaler surface", "Respirer", "Descendre", "Gonfler gilet"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "La toxicité CNS concerne :",
      answers: ["Azote", "Oxygène", "CO2", "Hélium"],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: "L’essoufflement augmente :",
      answers: ["CO2", "O2", "He", "Température"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Un gaz déco est utilisé pour :",
      answers: ["Raccourcir paliers", "Descendre plus vite", "Voir mieux", "Filmer"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "La narcose apparaît généralement :",
      answers: [">30m", "<10m", "Surface", "Toujours"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Une planification inclut :",
      answers: ["Profondeur, temps, gaz", "Météo TV", "Musique", "GPS"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "Le gradient factor concerne :",
      answers: ["Décompression", "Température", "Visibilité", "Lumière"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "L’hélium sert à :",
      answers: ["Réduire narcose", "Augmenter narcose", "Chauffer air", "Créer pression"],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: "La redondance signifie :",
      answers: ["Double équipement sécurité", "Double palier", "Double masque", "Double vitesse"],
      correctIndex: 0,
    ),
  ];
}
