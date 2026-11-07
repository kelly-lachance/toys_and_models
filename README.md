# Toys & Models – Tableau de bord de pilotage

Projet de groupe réalisé à la Wild Code School (octobre – novembre 2026), en équipe de 4 et en méthode Agile (5 sprints, Scrum et Kanban).

**Outils :** SQL (MySQL) · modélisation en étoile · Power BI · Power Query · DAX

![Page Ventes du tableau de bord](images/dashboard_ventes.jpg)

## Ma contribution

- **Modèle en étoile** : conception complète (choix du grain, tables de faits et de dimensions, clés) et écriture du script SQL de création et d'alimentation des tables.
- **Partie Ventes** : indicateurs de ventes et page Ventes du tableau de bord.
- **Mesures DAX** : contribution à l'écriture des mesures utilisées dans le tableau de bord.
- **Documentation** : rédaction et formalisation de la synthèse du projet (KPI, mesures DAX, choix de visualisation, enseignements, limites).

## Le besoin

Toys & Models vend des modèles réduits à des revendeurs dans le monde entier. Ses données de ventes étaient enregistrées dans une base transactionnelle, mais jamais exploitées.

Le directeur, qui n'est pas informaticien, voulait **un tableau de bord dynamique, actualisable chaque matin**, pour piloter son entreprise. Sa demande a été traduite en **18 indicateurs** répartis sur 4 domaines : ventes, finance, logistique et ressources humaines.

## La démarche

1. **Cadrage** : reformulation de la demande, priorisation des indicateurs, échanges avec la Product Owner pour lever les ambiguïtés.
2. **Audit des données** : exploration d'une base MySQL non documentée, calcul des premiers KPI en vues SQL, rédaction d'un dictionnaire de KPI.
3. **Modélisation** : construction d'un modèle en étoile directement dans la base SQL.
4. **Tableau de bord** : import dans Power BI, mesures DAX, une page par domaine, filtres et interactions.
5. **Contrôle qualité et restitution** : vérification croisée des chiffres, documentation, présentation orientée métier au directeur.

## Le modèle de données

Un modèle en étoile avec **2 tables de faits** et **4 dimensions** :

| Table | Grain / contenu |
| --- | --- |
| `fait_ventes` | 1 ligne = 1 produit d'une commande |
| `fait_payment` | 1 ligne = 1 paiement client |
| `dim_customers` | client, pays, limite de crédit |
| `dim_produit` | produit, gamme, stock, prix d'achat |
| `dim_employee` | commercial, bureau, territoire |
| `dim_date` | année, trimestre, mois (créée dans Power Query pour s'actualiser automatiquement) |

![Modèle de données dans Power BI](images/modele_powerbi.png)

Le script de création et d'alimentation des tables est dans [`sql/modele_etoile.sql`](sql/modele_etoile.sql).

## Exemples de mesures DAX

```dax
CA = SUM(fait_ventes[chiffre_affaire])

Prix achat = SUMX(fait_ventes, fait_ventes[quantityOrdered] * RELATED(dim_produit[buyPrice]))
Marge = [CA] - [Prix achat]
Taux marge = DIVIDE([Marge], [CA])

Nb commande = DISTINCTCOUNT(fait_ventes[orderNumber])
Panier moyen = DIVIDE([CA], [Nb commande])

Nb clients recurrents = COUNTROWS(FILTER(VALUES(fait_ventes[customerNumber]), [Nb commande] >= 2))
Nb client actif = DISTINCTCOUNT(fait_ventes[customerNumber])
Taux client recurrent = DIVIDE([Nb clients recurrents], [Nb client actif])
```

## Aperçu du tableau de bord

Une page par domaine, avec des filtres communs (année, trimestre, mois, territoire, bureau, client, catégorie, produit).

| Finances | Ressources humaines |
| --- | --- |
| ![Page Finances](images/dashboard_finances.jpg) | ![Page Ressources humaines](images/dashboard_rh.jpg) |

| Logistique | Accueil |
| --- | --- |
| ![Page Logistique](images/dashboard_logistique.jpg) | ![Page d'accueil](images/dashboard_accueil.jpg) |

La version complète est disponible en PDF : [`docs/tableau_de_bord.pdf`](docs/tableau_de_bord.pdf).

## Principaux enseignements

- **Une croissance de +30 % entre 2022 et 2023**, portée par l'Amérique du Nord et l'EMEA (84 % du CA). Seul le Japon recule (−43 %), à cause de la perte d'un client qui représentait plus de la moitié de son CA.
- **40 % de marge brute.** Le produit le plus vendu est aussi l'un des plus chers et le plus rentable : les prix élevés ne freinent pas les ventes. 18 produits à fort CA ont pourtant une marge inférieure à 30 % : une piste de révision des prix ou des remises.
- **97,7 % du CA encaissé**, mais une dépendance à quelques clients : un seul client représente 67 % du CA en Espagne.
- **Une performance commerciale concentrée** : 3 commerciaux réalisent 31 % du CA, et 2 commerciaux n'ont aucun client affecté.
- **Logistique** : 12 produits sous le seuil de stock critique, et un délai moyen de 4 jours entre la commande et l'expédition.

## Limites identifiées

- Les paiements sont rattachés aux clients, pas aux commandes : les soldes et taux de recouvrement sont donc des **estimations**, et le délai de paiement n'a pas pu être calculé.
- Les stocks ne sont mis à jour que tous les 2 mois : l'indicateur de stock est une alerte, pas un état en temps réel.
- La base ne contient aucun objectif commercial : l'objectif a été fixé par hypothèse à CA de l'année précédente + 5 %.
- 15 indicateurs sur 18 ont été livrés. Les 3 autres n'ont pas été présentés, notamment faute de lien entre paiements et commandes et de suivi des stocks en continu.

## Contenu du dépôt

| Dossier | Contenu |
| --- | --- |
| `sql/` | Script SQL de création et d'alimentation du modèle en étoile |
| `powerbi/` | Fichier Power BI du tableau de bord (.pbix) |
| `docs/` | Tableau de bord complet en PDF |
| `images/` | Captures du tableau de bord et schémas du modèle de données |

## Pour reproduire

1. Charger la base `toys_and_models` dans MySQL (fournie par la Wild Code School, non incluse dans ce dépôt).
2. Exécuter `sql/modele_etoile.sql` pour créer les tables de faits et de dimensions.
3. Ouvrir `powerbi/Toys_and_Models_dashboard.pbix` dans Power BI Desktop et mettre à jour la connexion MySQL.
