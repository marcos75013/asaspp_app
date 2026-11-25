String? validateCarpoolDeparture({
  required DateTime? departure,
  required DateTime eventStart,
  required DateTime now,
}) {
  if (departure == null) return 'Choisis une date et une heure de départ.';
  if (!departure.isAfter(now)) {
    return 'Le départ doit être dans le futur.';
  }
  if (departure.isAfter(eventStart)) {
    return 'Le départ doit être avant le début de l’événement.';
  }
  return null;
}
