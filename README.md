Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

Projet UrbanAssist 


Détail du fichier CSV :

Liste des champs et formats

| Nom du champ | Format | Exemple | Description rapide |
|--------------|--------|---------|-------------------|
| `insee_code` | string(5) | "01001" | Code INSEE commune |
| `name` | string | "L'ABERGEMENT-CLEMENCIAT" | Nom de la commune |
| `department` | string(2) | "01" | Département |
| `region` | string | "Auvergne-Rhône-Alpes" | Région |
| `avg_price_sqm` | decimal(10,2) | 3248.69 | Prix moyen €/m² |
| `median_price_sqm` | decimal(10,2) | 3212.09 | Prix médian €/m² |
| `total_transactions` | int | 27 | Nombre transactions 2024 |
| `transactions_last_year` | int | 27 | Transactions année dernière |
| `price_evolution_1y` | decimal(8,2) | 36.97 | Évolution 2023→2024 (%) |
| `price_evolution_3y` | decimal(8,2) | 14.21 | Évolution 2022→2024 (%) |
| `avg_rent_sqm` | decimal(10,2) | 12.37 | Loyer €/m²/mois |
| `rent_quality` | decimal(8,3) | 0.785 | Qualité prédiction (R²) |
| `nb_obs_commune` | decimal(10,1) | 10.0 | Nb observations commune |

15 colonnes
Taille typique : ~15-20 Mo

Sources :

DVF>>>Données brutes des transactions immobilières (Demandes de Valeurs Foncières)
Calculé DVF>>>Agrégation/calcul à partir des données DVF brutes
DHUP brut>>>Données brutes du modèle prédictif DHUP (Direction Habitat Urbanisme Paysages)
Calculé DVF+DHUP>>>Calcul combinant les deux sources (fusion)