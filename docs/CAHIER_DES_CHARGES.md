# Cahier des charges — Guinée Transport

**Synthèse structurée du cahier des charges** pour l’implémentation de la plateforme mobile.

---

## 1. Présentation du projet

| Élément | Détail |
|--------|--------|
| **Nom** | Guinée Transport |
| **Nature** | Application mobile sécurisée de **gestion**, **réservation** et **organisation** du transport interurbain. |
| **Ville pilote** | Labé |
| **Vision** | Extension nationale |
| **Finalité** | Moderniser, structurer et sécuriser le transport interurbain guinéen en intégrant : digitalisation, organisation syndicale numérique, intelligence artificielle, sécurité des usagers. |

---

## 2. Contexte et justification

**Problèmes actuels :**
- Gestion manuelle
- Absence de traçabilité numérique
- Conflits de zones entre syndicats
- Départs non structurés
- Manque de sécurité routière
- Absence de visibilité en temps réel

**Conséquences :**
- Perte de temps pour les passagers
- Revenus instables pour les chauffeurs
- Manque de contrôle structuré pour les syndicats
- Risques d’accidents élevés

**Réponse :** Structuration digitale complète via la plateforme.

---

## 3. Objectifs

### 3.1 Objectif principal
Mettre en place une plateforme mobile permettant :
- La **réservation de trajets interurbains**
- La **gestion numérique des gares et syndicats**
- L’**optimisation des revenus chauffeurs**
- La **réduction des risques routiers**

### 3.2 Objectifs spécifiques
- Sécuriser les données utilisateurs
- Structurer les zones syndicales
- Digitaliser les billets
- Introduire des alertes intelligentes (IA)
- Créer un modèle économique viable

---

## 4. Acteurs du système

### 4.1 Passager
- Recherche trajet
- Réservation
- Paiement
- Abonnement quotidien
- Historique

### 4.2 Chauffeur
- Gestion véhicule
- Visualisation passagers
- Confirmation départ
- Alertes IA (trafic / sécurité)
- Statistiques revenus

### 4.3 Syndicat (administrateur de zone par ville)
- Gestion des chauffeurs
- Gestion des véhicules
- Contrôle des départs
- Supervision gare
- Rapport financier

### 4.4 Administrateur global
- Gestion villes
- Gestion zones
- Supervision nationale
- Contrôle sécurité système

---

## 5. Description fonctionnelle

### 5.1 Authentification (obligatoire)
- **Email / mot de passe**
- **Session persistante**
- **Séparation stricte des rôles**
- **Aucune utilisation sans connexion**

### 5.2 Réservation
- Choix ville départ / arrivée
- Nombre de places
- Visualisation véhicule
- Confirmation

### 5.3 Abonnement
- Abonnement client ↔ chauffeur
- Paiement sécurisé
- Durée définie
- Historique des trajets

### 5.4 Gestion syndicale
- Chaque syndicat gère sa zone
- Aucune interférence inter-zone
- Validation des départs
- Suivi des véhicules entrants / sortants

### 5.5 Intelligence artificielle
- Alertes embouteillages
- Suggestion lieux de pause
- Alerte dépassement dangereux
- Analyse risque accident
- Historique comportement chauffeur

### 5.6 Système de billetterie
- Validation au départ
- Anti-duplication
- Traçabilité complète

---

## 6. Architecture technique

### 6.1 Frontend
- **Flutter**
- Architecture modulaire
- Navigation sécurisée par rôle

### 6.2 Backend
- **Supabase**
- **PostgreSQL**
- **Row Level Security (RLS)** sur les données

### 6.3 Sécurité
- Auth intégrée (Supabase Auth)
- Isolation des rôles
- Chiffrement JWT
- Politique anti-fraude
- Logs d’activité

---

## 7. Base de données (entités principales)

Toutes les entités sont **protégées par RLS**.

| Entité | Rôle |
|--------|------|
| `profiles` | Profils utilisateurs |
| `roles` | Rôles (passager, chauffeur, syndicat, admin) |
| `user_roles` | Liaison utilisateur ↔ rôle(s) |
| `cities` | Villes |
| `zones` | Zones (syndicats) |
| `stations` | Gares / points de départ-arrivée |
| `drivers` | Chauffeurs |
| `vehicles` | Véhicules |
| `routes` | Lignes / trajets (ex. Labé–Conakry) |
| `trips` | Départs / courses réelles |
| `bookings` | Réservations |
| `tickets` | Billets (anti-duplication, traçabilité) |
| `payments` | Paiements |
| `traffic_alerts` | Alertes trafic (IA) |
| `safety_events` | Événements sécurité |

---

## 8. Modèle économique

### 8.1 Revenus syndicats
- Commission par réservation
- Commission abonnement
- Cotisation chauffeurs
- Tableau financier automatisé

### 8.2 Revenus chauffeurs
- Optimisation remplissage
- Abonnements réguliers
- Réduction temps d’attente
- Bonus performance

### 8.3 Revenus plateforme
- Commission par trajet
- Services IA avancés

---

## 9. Impact social
- Réduction accidents
- Réduction désordre en gare
- Sécurité étudiants
- Digitalisation nationale
- Création emploi numérique
- Modernisation transport

---

## 10. Exigences non fonctionnelles
- Performance rapide
- Sécurité maximale
- Évolutivité nationale
- Interface professionnelle
- UX claire et intuitive

---

## 11. Contraintes
- Adaptation au contexte guinéen
- Intégration syndicats existants
- Acceptation progressive
- Formation utilisateurs

---

## 12. Plan de déploiement
- **Phase 1 :** Labé
- **Phase 2 :** Conakry
- **Phase 3 :** Extension nationale
- **Phase 4 :** IA avancée

---

## 13. Indicateurs de succès
- Nombre de réservations
- Taux de remplissage
- Revenus syndicats
- Réduction accidents
- Taux d’abonnement

---

## 14. Conclusion
Guinée Transport = solution technologique + outil d’organisation syndicale pour un transport interurbain moderne et sécurisé en Guinée.

---

*Document de référence pour l’implémentation. À utiliser avec les maquettes pour l’UI/UX.*
